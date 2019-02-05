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
  $SHELLSPEC_SHELL "$SHELLSPEC_LIBEXEC/shellspec-reporter.sh" &&:
  ret=$?
  if [ $ret -ne 0 ] && [ $ret -ne "$SHELLSPEC_SPEC_FAILURE_CODE" ]; then
    error "Raised error in reporter."
  fi
  return $ret
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
}

# I want to process with non-blocking output
# and the stdout of runner streams to the reporter
# and capture stderr both of the runner and the reporter
# and the stderr streams to error hander
# and also handle both exit status. As a result of
[ $# -eq 0 ] && set -- 'spec'
( ( ( ( ( set -e; runner "$@"); echo $? >&5) \
  | reporter >&3; echo $? >&5) 2>&1 \
  | error_handler >&4) 5>&1 \
  | {
      read -r xs1; read -r xs2
      if [ "$xs2" -gt 0 ]; then exit "$xs2"; else exit "$xs1"; fi
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
