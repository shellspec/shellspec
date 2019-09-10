#!/bin/sh
#shellcheck disable=SC2004

set -eu

export SHELLSPEC_PROFILER_SIGNAL="$SHELLSPEC_TMPBASE/profiler.signal"

# shellcheck source=lib/libexec/runner.sh
. "${SHELLSPEC_LIB:-./lib}/libexec/runner.sh"

start_profiler() {
  [ "$SHELLSPEC_PROFILER" ] || return 0
  $SHELLSPEC_SHELL "$SHELLSPEC_LIBEXEC/shellspec-profiler.sh" &
} 2>/dev/null

stop_profiler() {
  [ "$SHELLSPEC_PROFILER" ] || return 0
  if [ -e "$SHELLSPEC_PROFILER_SIGNAL" ]; then
    rm "$SHELLSPEC_PROFILER_SIGNAL"
  fi
}

cleanup() {
  if (trap - INT) 2>/dev/null; then trap '' INT; fi
  [ "$SHELLSPEC_TMPBASE" ] || return 0
  tmpbase="$SHELLSPEC_TMPBASE" && SHELLSPEC_TMPBASE=''
  [ -f "$SHELLSPEC_KCOV_IN_FILE" ] && rm "$SHELLSPEC_KCOV_IN_FILE"
  [ "$SHELLSPEC_KEEP_TEMPDIR" ] || rmtempdir "$tmpbase"
}

interrupt() {
  trap '' TERM # Workaround for posh: Prevent display 'Terminated'.
  stop_profiler
  reporter_pid=''
  read_pid_file reporter_pid "$SHELLSPEC_TMPBASE/reporter.pid" 0
  [ "$reporter_pid" ] && sleep_wait signal -0 "$reporter_pid" 2>/dev/null
  signal -TERM 0
  cleanup
  exit 130
}

executor() {
  start_profiler
  executor="$SHELLSPEC_LIBEXEC/shellspec-executor.sh"
  # shellcheck disable=SC2086
  $SHELLSPEC_TIME $SHELLSPEC_SHELL "$executor" "$@" 3>&2 2>"$SHELLSPEC_TIME_LOG"
  stop_profiler
}

reporter() {
  $SHELLSPEC_SHELL "$SHELLSPEC_LIBEXEC/shellspec-reporter.sh" "$@"
}

error_handler() {
  error_occurred=''

  while IFS= read -r line; do
    error_occurred=1
    error "$line"
  done

  if [ "$error_occurred" ]; then
    exit "$SHELLSPEC_UNEXPECTED_STDERR"
  fi
}

set_exit_status() {
  return "$1"
}

if (trap - INT) 2>/dev/null; then trap 'interrupt' INT; fi
if (trap - TERM) 2>/dev/null; then trap ':' TERM; fi
trap 'cleanup' EXIT

mktempdir "$SHELLSPEC_TMPBASE"

if [ "$SHELLSPEC_KEEP_TEMPDIR" ]; then
  warn "Keeping temporary directory. "
  warn "Manually delete: rm -rf \"$SHELLSPEC_TMPBASE\""
fi

if [ "$SHELLSPEC_BANNER" ] && [ -e "$SHELLSPEC_BANNER" ]; then
  display "$SHELLSPEC_BANNER"
fi

if [ "${SHELLSPEC_RANDOM:-}" ]; then
  export SHELLSPEC_LIST
  SHELLSPEC_LIST=$SHELLSPEC_RANDOM
  exec="$SHELLSPEC_LIBEXEC/shellspec-list.sh"
  eval "$SHELLSPEC_SHELL" "\"$exec\"" ${1+'"$@"'} >"$SHELLSPEC_INFILE"
  set -- -
fi

# I want to process with non-blocking output
# and the stdout of runner streams to the reporter
# and capture stderr both of the runner and the reporter
# and the stderr streams to error hander
# and also handle both exit status. As a result of
( ( ( ( set -e; executor "$@"; echo $? >&5 ) \
  | reporter "$@" >&3; echo $? >&5 ) 2>&1 \
  | error_handler >&4; echo $? >&5 ) 5>&1 \
  | (
      read -r xs1; read -r xs2; read -r xs3
      if [ "$xs2" = "$SHELLSPEC_SPEC_FAILURE_CODE" ]; then
        xs=$SHELLSPEC_SPEC_FAILURE_CODE
      else
        for xs in "$xs1" "$xs2" "$xs3"; do
          case $xs in (0 | "") continue; esac
          error "An unexpected error occurred or output to the stderr." \
            "[$xs1] [$xs2] [$xs3]"
          break
        done
      fi
      set_exit_status "${xs:-1}"
    )
) 3>&1 4>&2 &&:
exit_status=$?

if [ -e "$SHELLSPEC_TMPBASE/profiler.timeout" ]; then
  warn "Forced terminate the profiler due to a timed out" \
    "(Occasionally occurs with zsh)."
fi

case $exit_status in
  0) ;; # Running specs exit with successfully.
  "$SHELLSPEC_SPEC_FAILURE_CODE") ;; # Running specs exit with failure.
  *) error "Fatal error occurred, terminated with exit status $exit_status."
esac

exit "$exit_status"
