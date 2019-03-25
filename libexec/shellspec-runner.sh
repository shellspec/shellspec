#!/bin/sh

set -eu

[ "${ZSH_VERSION:-}" ] && setopt shwordsplit

: "${SHELLSPEC_TIME:=time -p}"

# shellcheck source=lib/general.sh
. "${SHELLSPEC_LIB:-./lib}/general.sh"
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

runner() {
  translator="$SHELLSPEC_LIBEXEC/shellspec-translator.sh"
  # shellcheck disable=SC2086
  ( (command $SHELLSPEC_TIME $SHELLSPEC_SHELL "$translator" "$@" 2>&1 >&3 ) \
    | trans_log >&2) 3>&1 | command $SHELLSPEC_TIME $SHELLSPEC_SHELL
}

reporter() {
  $SHELLSPEC_SHELL "$SHELLSPEC_LIBEXEC/shellspec-reporter.sh"
}

trans_log() {
  while IFS= read -r line; do
    time_result "$line" >> "$SHELLSPEC_TRANS_LOG" && continue
    echo "$line"
  done
}

error_handler() {
  marker='' error_file=''
  while IFS= read -r line; do
    if time_result "$line" >> "$SHELLSPEC_TIME_LOG.tmp"; then
      if includes "$line" "sys "; then
        mv "$SHELLSPEC_TIME_LOG.tmp" "$SHELLSPEC_TIME_LOG"
      fi
    else
      case $line in
        ${SHELLSPEC_SYN}shellspec_marker:*)
          if [ "${first_error-1}" ]; then
            line=${line#${SHELLSPEC_SYN}shellspec_marker:}
            marker=${line%%${SHELLSPEC_TAB}*}
            error_file=${line#*${SHELLSPEC_TAB}}
          fi
          ;;
        *)
          [ "${first_error-1}" ] && first_error='' && error
          error "$line"
        ;;
      esac
    fi
  done

  display_unexpected_error "$marker" "$error_file"

  if [ "${first_error+x}" ]; then
    exit "$SHELLSPEC_UNEXPECTED_STDERR"
  fi
}

display_unexpected_error() {
  specfile=${1% *} lineno=${1##* } error_file=$2
  [ "$specfile" ] || return 0
  case $lineno in
    BOF) lineno=1 ;;
    EOF) return 0 ;; # no error
    *) ;;
  esac

  range=$(detect_range "$lineno" < "$specfile")
  if [ -e "$error_file" ]; then
    readfile error "$error_file"
    error=$(puts "$error")
    error "$error"
  fi
  error "The specfile aborted at line $range in '$specfile'"
  error
}

is_block_statement() {
  case $1 in (Describe | Context | Example | Specify | It | End)
    return 0
  esac
  return 1
}

detect_range() {
  lineno_begin=$1 lineno_end= lineno=0
  while IFS= read -r line || [ "$line" ]; do
    trim line
    line=${line%% *}
    line=${line#x}
    lineno=$(($lineno + 1))
    [ "$lineno" -lt "$1" ] && continue
    if [ "$lineno" -eq "$1" ]; then
      is_block_statement "$line" && lineno_begin=$(($lineno + 1))
    else
      is_block_statement "$line" && lineno_end=$(($lineno - 1)) && break
    fi
  done
  echo "${lineno_begin}-${lineno_end:-$lineno}"
}

# I want to process with non-blocking output
# and the stdout of runner streams to the reporter
# and capture stderr both of the runner and the reporter
# and the stderr streams to error hander
# and also handle both exit status. As a result of
[ $# -eq 0 ] && set -- 'spec'
( ( ( ( ( set -e; runner "$@"); echo $? >&5) \
  | reporter >&3; echo $? >&5) 2>&1 \
  | error_handler >&4; echo $? >&5) 5>&1 \
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
) 3>&1 4>&2 &&:
exit_status=$?

wait

case $exit_status in
  0) exit 0;; # Running specs exit with successfully.
  $SHELLSPEC_SPEC_FAILURE_CODE) ;; # Running specs exit with failure.
  *) error "Fatal error occurred, terminated with exit status $exit_status."
esac

exit "$exit_status"
