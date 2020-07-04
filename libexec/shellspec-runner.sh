#!/bin/sh
#shellcheck disable=SC2004

set -eu

export SHELLSPEC_PROFILER_SIGNAL="$SHELLSPEC_TMPBASE/profiler.signal"
SHELLSPEC_PATH=${SHELLSPEC_PATH:-$PATH}

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
  set -- "$SHELLSPEC_TMPBASE" && SHELLSPEC_TMPBASE=''
  [ "$SHELLSPEC_KEEP_TEMPDIR" ] && return 0
  [ "$1" ] || return 0
  { rmtempdir "$1" & } 2>/dev/null
}

interrupt() {
  trap '' TERM # Workaround for posh: Prevent display 'Terminated'.
  stop_profiler
  reporter_pid=''
  read_pid_file reporter_pid "$SHELLSPEC_TMPBASE/$SHELLSPEC_REPORTER_PID" 0
  [ "$reporter_pid" ] && sleep_wait sigchk "$reporter_pid"
  sigterm 0 &&:
  cleanup
  exit 130
}

executor() {
  start_profiler
  executor="$SHELLSPEC_LIBEXEC/shellspec-executor.sh"
  # shellcheck disable=SC2086
  $SHELLSPEC_TIME $SHELLSPEC_SHELL "$executor" "$@" 3>&2 2>"$SHELLSPEC_TIME_LOG"
  eval "stop_profiler; return $?"
}

reporter() {
  $SHELLSPEC_SHELL "$SHELLSPEC_LIBEXEC/shellspec-reporter.sh" "$@"
}

error_handler() {
  error_count=0

  while IFS= read -r line; do
    error_count=$(($error_count + 1))
    error "$line"
  done

  [ "$error_count" -eq 0 ] || exit "$SHELLSPEC_STDERR_OUTPUT_CODE"
}

if (trap - INT) 2>/dev/null; then trap 'interrupt' INT; fi
if (trap - TERM) 2>/dev/null; then trap ':' TERM; fi
trap 'cleanup' EXIT

if [ "$SHELLSPEC_REPAIR" ]; then
  if [ -e "$SHELLSPEC_QUICK_FILE" ]; then
    SHELLSPEC_QUICK=1
  else
    warn "Quick Mode is disabled. Run with --quick option first."
    exit
  fi
fi

if [ "$SHELLSPEC_QUICK" ]; then
  if ! [ -e "$SHELLSPEC_QUICK_FILE" ]; then
    if ( : > "$SHELLSPEC_QUICK_FILE" ) 2>/dev/null; then
      warn "Quick Mode is automatically enabled." \
        "If you want disable it, delete '$SHELLSPEC_QUICK_FILE'."
    else
      warn "Failed to enable Quick Mode " \
        "due to failed to create '$SHELLSPEC_QUICK_FILE'."
    fi
  fi

  if [ -e "$SHELLSPEC_QUICK_FILE" ]; then
    count=$# line='' last_line=''
    while read_quickfile line state "$SHELLSPEC_REPAIR"; do
      [ "$last_line" = "$line" ] && continue || last_line=$line
      match_quick_data "$line" "$@" && set -- "$@" "$line"
    done < "$SHELLSPEC_QUICK_FILE"
    if [ "$#" -gt "$count" ] && shift "$count"; then
      warn "Run only not-passed examples the last time they ran."
      export SHELLSPEC_PATTERN="*"
    elif [ "$SHELLSPEC_REPAIR" ]; then
      warn "No failed examples were found."
      exit
    fi
  fi
fi

quick_mode='' info='' info_extra=$SHELLSPEC_INFO
[ -e "$SHELLSPEC_QUICK_FILE" ] && quick_mode="<quick mode> "
[ "$SHELLSPEC_QUICK" ] && info="${info}--quick "
[ "$SHELLSPEC_REPAIR" ] && info="${info}--repair "
if [ "$SHELLSPEC_FAIL_FAST_COUNT" ]; then
  info="${info}--fail-fast $SHELLSPEC_FAIL_FAST_COUNT " && info="${info% 1 } "
fi
[ "$SHELLSPEC_WORKERS" -gt 0 ] && info="${info}--jobs $SHELLSPEC_WORKERS "
[ "$SHELLSPEC_DRYRUN" ] && info="${info}--dry-run "
[ "$SHELLSPEC_XTRACE" ] && info="${info}--trace${SHELLSPEC_XTRACE_ONLY:+-only} "
[ "$SHELLSPEC_RANDOM" ] && info="${info}--random $SHELLSPEC_RANDOM "
[ "$info" ] && info="{${info% }}"
SHELLSPEC_INFO="${quick_mode}${info}${info_extra:+ }${info_extra}"

mktempdir "$SHELLSPEC_TMPBASE"

if [ "$SHELLSPEC_KEEP_TEMPDIR" ]; then
  warn "Keeping temporary directory. "
  warn "Manually delete: rm -rf \"$SHELLSPEC_TMPBASE\""
fi

[ -s "$SHELLSPEC_BANNER" ] && cat "$SHELLSPEC_BANNER"

if [ "${SHELLSPEC_RANDOM:-}" ]; then
  export SHELLSPEC_LIST=$SHELLSPEC_RANDOM
  exec="$SHELLSPEC_LIBEXEC/shellspec-list.sh"
  eval "$SHELLSPEC_SHELL" "\"$exec\"" ${1+'"$@"'} >"$SHELLSPEC_INFILE"
  set -- -
fi

# I want to process with non-blocking output
# and the stdout of runner streams to the reporter
# and capture stderr both of the runner and the reporter
# and the stderr streams to error hander
# and also handle both exit status. As a result of
( ( ( ( set -e; { executor "$@"; } 9>&1 >&8; echo $? >&5 ) \
  | reporter "$@" >&3; echo $? >&5 ) 2>&1 \
  | error_handler >&4; echo $? >&5 ) 5>&1 \
  | (
      read -r xs1; read -r xs2; read -r xs3
      case $SHELLSPEC_SPEC_FAILURE_CODE in
        "$xs1" | "$xs2") xs=$SHELLSPEC_SPEC_FAILURE_CODE ;;
        *)
          for xs in "$xs1" "$xs2" "$xs3"; do
            [ "${xs#0}" ] || continue
            error "An unexpected error occurred." \
              "[executor: $xs1] [reporter: $xs2] [error handler: $xs3]"
            break
          done
      esac
      set_exit_status "${xs:-1}"
    )
) 3>&1 4>&2 8>&1 &&:
exit_status=$?

case $exit_status in
  0) ;; # Running specs exit with successfully.
  "$SHELLSPEC_SPEC_FAILURE_CODE") ;; # Running specs exit with failure.
  *) error "Fatal error occurred, terminated with exit status $exit_status."
esac

exit "$exit_status"
