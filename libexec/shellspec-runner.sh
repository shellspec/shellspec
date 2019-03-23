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
    printf '\33[2;31m%s\33[0m\n' "${1:-}" >&2
  else
    printf '%s\n' "${1:-}" >&2
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
  while IFS= read -r line; do
    if time_result "$line" >> "$SHELLSPEC_TIME_LOG.tmp"; then
      if includes "$line" "sys "; then
        mv "$SHELLSPEC_TIME_LOG.tmp" "$SHELLSPEC_TIME_LOG"
      fi
    else
      [ "${first_error-1}" ] && first_error='' && error
      error "$line"
    fi
  done
  if [ "${first_error+x}" ]; then
    error "The runner output error that can not handle by the reporter."
    exit 1
  fi
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
      xs="[$xs1] [$xs2] [$xs3]"
      case $xs in
        '[0] [0] [0]') exit 0 ;;
        "[$SHELLSPEC_SPEC_FAILURE_CODE] [0] [0]") ;;
        "[0] [$SHELLSPEC_SPEC_FAILURE_CODE] [0]") ;;
        "[0] [0] [$SHELLSPEC_SPEC_FAILURE_CODE]") ;;
        *)
          error "An unexpected error occurred in the runner or the reporter. $xs"
          exit 1
      esac
      exit "$SHELLSPEC_SPEC_FAILURE_CODE"
    }
) 3>&1 4>&2 &&:
exit_status=$?

wait

case $exit_status in
  0) exit 0;; # Running specs exit with successfully.
  $SHELLSPEC_SPEC_FAILURE_CODE) ;; # Running specs exit with failure.
  *) error "Fatal error occurred, terminated with exit status $exit_status."
esac

exit 1
