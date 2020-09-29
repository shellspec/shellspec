#shellcheck shell=sh disable=SC2004

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"
use sequence

worker() {
  job() {
    # posh 0.10.2 workaround: uses mkdir instead of set -C
    (mkdir "$SHELLSPEC_JOBDIR/$1.lock") 2>/dev/null || return 0
    IFS= read -r specfile < "$SHELLSPEC_JOBDIR/$1.job"
    translator --no-metadata --no-finished --spec-no="$1" "$specfile" \
      | eval "\$SHELLSPEC_SHELL" \
        "$SHELLSPEC_OUTPUT_FD> \"\$SHELLSPEC_JOBDIR/\$1.stdout\"" \
        "2> \"\$SHELLSPEC_JOBDIR/\$1.stderr\" &&:" &&:
    echo "$?" > "$SHELLSPEC_JOBDIR/$1.status"
    : > "$SHELLSPEC_JOBDIR/$1.done"
  }
  sequence job 1 "$2"
}

reduce() {
  i=0
  while [ $i -lt "$1" ] && i=$(($i + 1)); do
    sleep_wait_until [ -e "$SHELLSPEC_JOBDIR/$i.done" ]
    # shellcheck disable=SC2039,SC3021
    cat "$SHELLSPEC_JOBDIR/$i.stdout" >&"$SHELLSPEC_OUTPUT_FD"
    cat "$SHELLSPEC_JOBDIR/$i.stderr" >&2
    read -r exit_status < "$SHELLSPEC_JOBDIR/$i.status"
    [ "$exit_status" -eq 0 ] || exit "$exit_status"
  done
}

executor() {
  jobs=0 workers=''
  # shellcheck disable=SC2016
  "$SHELLSPEC_TRAP" 'eval "terminator $workers"' INT

  SHELLSPEC_JOBDIR="$SHELLSPEC_TMPBASE/jobs"
  mkdir "$SHELLSPEC_JOBDIR"

  specfile() {
    jobs=$(($jobs + 1))
    putsn "$1" > "$SHELLSPEC_JOBDIR/$jobs.job"
  }
  eval find_specfiles specfile ${1+'"$@"'}
  create_workdirs "$jobs"

  translator --no-finished | $SHELLSPEC_SHELL # output only metadata
  # Workaround for osh: Use FD3 to avoid display "Started PID"
  callback() {
    { worker "$1" "$jobs" 2>&3 & } 3>&2 2>/dev/null
    workers="$workers $!"
  }
  sequence callback 1 "$SHELLSPEC_WORKERS"
  (reduce "$jobs") &&:
  eval "[ $? -ne 0 ] && return $?"
  translator --no-metadata | $SHELLSPEC_SHELL # output only finished
}

terminator() {
  [ $# -eq 0 ] || kill "$@"
}
