#!/bin/sh
#shellcheck disable=SC2004

set -eu

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
  "$SHELLSPEC_TRAP" '' INT
  set -- "$SHELLSPEC_TMPBASE" && SHELLSPEC_TMPBASE=''
  [ "$SHELLSPEC_KEEP_TMPDIR" ] && return 0
  [ "$1" ] || return 0
  { rmtempdir "$1" & } 2>/dev/null
}

interrupt() {
  "$SHELLSPEC_TRAP" '' TERM # Workaround for posh: Prevent display 'Terminated'.
  stop_profiler
  reporter_pid=''
  read_pid_file reporter_pid "$SHELLSPEC_REPORTER_PID" 0
  [ "$reporter_pid" ] && sleep_wait signal 0 "$reporter_pid" 2>/dev/null
  signal TERM 0 2>/dev/null &&:
  cleanup
  exit 130
}

precheck() {
  export VERSION="$SHELLSPEC_VERSION"
  export SHELL_VERSION="$SHELLSPEC_SHELL_VERSION"
  export SHELL_TYPE="$SHELLSPEC_SHELL_TYPE"

  eval "set -- $1"
  [ $# -gt 0 ] || return 0

  status_file=$SHELLSPEC_PRECHECKER_STATUS
  echo "-" > "$status_file"
  for module; do
    import_path=''
    resolve_module_path import_path "$module"
    if [ ! -r "$import_path" ]; then
      echo "Unable to load the required module '$module': $import_path" >&2
      exit 1
    fi
    set -- "$@" "$import_path"
    shift
  done
  prechecker="$SHELLSPEC_LIBEXEC/shellspec-prechecker.sh"
  # shellcheck disable=SC2086
  $SHELLSPEC_SHELL "$prechecker" --warn-fd=3 --status-file="$status_file" "$@"
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

  [ "$error_count" -eq 0 ] || exit "$SHELLSPEC_ERROR_EXIT_CODE"
}

"$SHELLSPEC_TRAP" 'interrupt' INT
"$SHELLSPEC_TRAP" ':' TERM
trap 'cleanup' EXIT

check_formatters() {
  eval "set -- $1"
  for module; do
    module_exists "${module}_formatter" && continue
    abort "The specified formatter '$module' is not found."
  done
}
check_formatters "$SHELLSPEC_FORMATTER $SHELLSPEC_GENERATORS"

for p; do
  [ -f "$p" ] || continue
  is_specfile "$p" && continue
  abort "File '$p' cannot be executed because it does not match the pattern '$SHELLSPEC_PATTERN'."
done

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

if [ "$SHELLSPEC_KEEP_TMPDIR" ]; then
  warn "Keeping temporary directory."
  warn "Manually delete: rm -rf \"$SHELLSPEC_TMPBASE\""
fi

noexec_check="$SHELLSPEC_TMPBASE/.shellspec-check-executable"
echo '#!/bin/sh' > "$noexec_check"
"$SHELLSPEC_CHMOD" +x "$noexec_check"
if ! "$noexec_check" 2>/dev/null; then
  export SHELLSPEC_NOEXEC_TMPDIR=1
  warn "Some features will not work properly because files under" \
    "the tmp directory (mounted with noexec option?) cannot be executed."
fi

if [ "$SHELLSPEC_BANNER" ]; then
  if [ -s "$SHELLSPEC_BANNER_FILE" ]; then
    cat "$SHELLSPEC_BANNER_FILE"
  elif [ -s "$SHELLSPEC_BANNER_FILE.md" ]; then
    cat "$SHELLSPEC_BANNER_FILE.md"
  fi
fi

if [ "${SHELLSPEC_RANDOM:-}" ]; then
  export SHELLSPEC_LIST=$SHELLSPEC_RANDOM
  exec="$SHELLSPEC_LIBEXEC/shellspec-list.sh"
  eval "$SHELLSPEC_SHELL" "\"$exec\"" ${1+'"$@"'} >"$SHELLSPEC_INFILE"
  set -- -
fi

{
  env=$( ( ( ( (
    ( ( precheck "$SHELLSPEC_REQUIRES" ) &&:; echo "exit_status=$?" >&9; ) >&8
    ) 2>&1 | while IFS= read -r line; do error "$line"; done >&2
    ) 3>&1 | while IFS= read -r line; do warn "$line"; done >&2
    ) 4>&1 | while IFS= read -r line; do info "$line"; done >&8
  ) 9>&1 )
  eval "$env"
} 8>&1
[ -s "$SHELLSPEC_PRECHECKER_STATUS" ] && exit "$exit_status"

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
      xs='' error='' msg="Aborted with status code"
      for i in "$xs1" "$xs2" "$xs3"; do
        case $i in
          0) continue ;;
          "$SHELLSPEC_FAILURE_EXIT_CODE") [ "$xs" ] || xs=$i ;;
          "$SHELLSPEC_ERROR_EXIT_CODE") xs=$i error=1 && break ;;
          *) [ "${xs#$SHELLSPEC_FAILURE_EXIT_CODE}" ] || xs=$i; error=1
        esac
      done
      if [ "$error" ]; then
        error "$msg [executor: $xs1] [reporter: $xs2] [error handler: $xs3]"
      fi
      set_exit_status "${xs:-0}"
    )
) 3>&1 4>&2 8>&1 &&:
exit_status=$?

case $exit_status in
  0) ;; # Running specs exit with successfully.
  "$SHELLSPEC_FAILURE_EXIT_CODE") ;; # Running specs exit with failure.
  *) error "Fatal error occurred, terminated with exit status $exit_status."
esac

exit "$exit_status"
