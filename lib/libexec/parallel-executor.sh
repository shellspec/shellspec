#shellcheck shell=sh disable=SC2004

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"
use sequence

worker() {
  job() {
    # posh 0.10.2 workaround: uses mkdir instead of set -C
    (mkdir "$SHELLSPEC_JOBDIR/$1.lock") 2>/dev/null || return 0
    IFS= read -r specfile < "$SHELLSPEC_JOBDIR/$1.job"
    translator --no-metadata --no-finished --spec-no=$(($1 + 1)) "$specfile" \
      | $SHELLSPEC_SHELL \
      > "$SHELLSPEC_JOBDIR/$1.stdout" 2> "$SHELLSPEC_JOBDIR/$1.stderr" &&:
    echo "$?" > "$SHELLSPEC_JOBDIR/$1.status"
    : > "$SHELLSPEC_JOBDIR/$1.done"
  }
  sequence job 0 $(($jobs - 1))
}

reduce() {
  i=0
  while [ $i -lt "$jobs" ]; do
    [ -e "$SHELLSPEC_JOBDIR/$i.done" ] || { sleep 0; continue; }
    display "$SHELLSPEC_JOBDIR/$i.stdout"
    display "$SHELLSPEC_JOBDIR/$i.stderr" >&2
    read -r exit_status < "$SHELLSPEC_JOBDIR/$i.status"
    [ "$exit_status" -ne 0 ] && exit "$exit_status"
    i=$(($i + 1))
  done
}

executor() {
  SHELLSPEC_JOBDIR="$SHELLSPEC_TMPBASE/jobs"

  mkdir "$SHELLSPEC_JOBDIR"

  jobs=0
  specfile() {
    putsn "$1" > "$SHELLSPEC_JOBDIR/$jobs.job"
    jobs=$(($jobs + 1))
  }
  eval find_specfiles specfile ${1+'"$@"'}

  translator --no-finished | $SHELLSPEC_SHELL # output only metadata
  callback() { worker "$1" & }
  sequence callback 0 $(($SHELLSPEC_JOBS-1))
  reduce
  translator --no-metadata | $SHELLSPEC_SHELL # output only finished
}
