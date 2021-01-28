#shellcheck shell=sh disable=SC2004

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"
use sequence

worker() {
  job() {
    # posh 0.10.2 workaround: uses mkdir instead of set -C
    jobfile="$SHELLSPEC_JOBDIR/$1"
    ( mkdir "$jobfile.lock" ) 2>/dev/null || return 0
    IFS= read -r specfile < "$jobfile.job"
    translator --no-metadata --no-finished --spec-no="$1" "$specfile" \
      | $SHELLSPEC_SHELL >"$jobfile.stdout" 2>"$jobfile.stderr" &&:
    echo "$?" > "$jobfile.status"
    : > "$jobfile.done"
  }
  sequence job 1 "$2"
}

reduce() {
  i=0
  while [ $i -lt "$1" ] && i=$(($i + 1)); do
    jobfile="$SHELLSPEC_JOBDIR/$i"
    sleep_wait_until [ -e "$jobfile.done" ]
    # shellcheck disable=SC2039,SC3021
    cat "$jobfile.stdout"
    cat "$jobfile.stderr" >&2
    read -r exit_status < "$jobfile.status"
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
  callback() { worker "$1" "$jobs" & nap; workers="$workers $!"; }
  sequence callback 1 "$SHELLSPEC_WORKERS"
  ( reduce "$jobs" ) &&:
  eval "[ $? -eq 0 ] || return $?"
  translator --no-metadata | $SHELLSPEC_SHELL # output only finished
}

terminator() {
  [ $# -eq 0 ] || kill "$@"
}
