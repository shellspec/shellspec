#!/bin/sh
#shellcheck disable=SC2004

set -eu

# shellcheck source=lib/libexec/runner.sh
. "${SHELLSPEC_LIB:-./lib}/libexec/runner.sh"

error() {
  if [ "$SHELLSPEC_COLOR" ]; then
    printf '\33[2;31m%s\33[0m\n' "${*:-}" >&2
  else
    printf '%s\n' "${*:-}" >&2
  fi
}

mktempdir "$SHELLSPEC_TMPBASE"
cleanup() {
  [ "$SHELLSPEC_TMPBASE" ] || return 0
  rmtempdir "$SHELLSPEC_TMPBASE"
  SHELLSPEC_TMPBASE=''
}
trap 'cleanup' EXIT

interrupt=''
interrupt() {
  if ! [ "$interrupt" ]; then
    interrupt=1
    echo
    echo "shellspec is shutting down and will print the summary report..." \
         "Interrupt again to force quit."
    sleep 2
    exit 130
  fi
}
if (trap '' INT) 2>/dev/null; then trap 'interrupt' INT; fi
if (trap '' TERM) 2>/dev/null; then trap 'exit 143' TERM; fi

executor() {
  $SHELLSPEC_SHELL "$SHELLSPEC_LIBEXEC/shellspec-executor.sh" "$@"
}

reporter() {
  $SHELLSPEC_SHELL "$SHELLSPEC_LIBEXEC/shellspec-reporter.sh" "$@"
}

error_handler() {
  marker='' error_file=''
  while IFS= read -r line; do
    case $line in
      ${SHELLSPEC_SYN}shellspec_marker:*)
        [ "${first_error-1}" ] || continue
        line=${line#${SHELLSPEC_SYN}shellspec_marker:}
        marker=${line%%${SHELLSPEC_TAB}*}
        error_file=${line#*${SHELLSPEC_TAB}}
        ;;
      *)
        [ "${first_error-1}" ] && first_error='' && error
        error "$line"
        ;;
    esac
  done

  display_unexpected_error "$marker" "$error_file"

  if [ "${first_error+x}" ]; then
    exit "$SHELLSPEC_UNEXPECTED_STDERR"
  fi
}

display_unexpected_error() {
  specfile=${1% *} lineno=${1##* } error_file=$2 error=''
  [ "$specfile" ] || return 0
  case $lineno in
    BOF) lineno=1 ;;
    EOF) return 0 ;; # no error
  esac

  range=$(detect_range "$lineno" < "$specfile")
  if [ -e "$error_file" ]; then
    readfile error "$error_file"
    error "$(puts "$error")"
  fi
  error "The specfile aborted at line $range in '$specfile'"
  error
}

# I want to process with non-blocking output
# and the stdout of runner streams to the reporter
# and capture stderr both of the runner and the reporter
# and the stderr streams to error hander
# and also handle both exit status. As a result of
{ { { { set -e; executor "$@"; echo $? >&5; } \
  | reporter "$@" >&3; echo $? >&5; } 2>&1 \
  | error_handler >&4; echo $? >&5; } 5>&1 \
  | {
      read -r xs1; read -r xs2; read -r xs3
      for xs in "$xs1" "$xs2" "$xs3"; do
        case $xs in
          0) ;;
          $SHELLSPEC_SPEC_FAILURE_CODE) break ;;
          *)
            error "An unexpected error occurred or output to the stderr." \
              "[$xs1] [$xs2] [$xs3]"
            break
        esac
      done
      exit "$xs"
    }
} 3>&1 4>&2 &&:
exit_status=$?

case $exit_status in
  0) exit 0;; # Running specs exit with successfully.
  $SHELLSPEC_SPEC_FAILURE_CODE) ;; # Running specs exit with failure.
  *) error "Fatal error occurred, terminated with exit status $exit_status."
esac

exit "$exit_status"
