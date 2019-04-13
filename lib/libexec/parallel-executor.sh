#shellcheck shell=sh disable=SC2004

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"
use sequence

worker() {
  job() {
    mv "$SHELLSPEC_JOBDIR/$1.job" "$SHELLSPEC_JOBDIR/$1.job#" 2>/dev/null || return 0
    IFS= read -r specfile < "$SHELLSPEC_JOBDIR/$1.job#"
    {
      if [ "$1" -eq 0 ]; then
        translator --metadata "$specfile" | shell
      else
        translator "$specfile" | shell
      fi
    } > "$SHELLSPEC_JOBDIR/$1.stdout#" 2> "$SHELLSPEC_JOBDIR/$1.stderr#" &&:
    echo "$?" > "$SHELLSPEC_JOBDIR/$1.status#"
    for ext in stdout stderr status; do
      mv "$SHELLSPEC_JOBDIR/$1.$ext#" "$SHELLSPEC_JOBDIR/$1.$ext"
    done
  }
  sequence job 0 $(($jobs - 1))
}

reduce() {
  i=0
  while [ $i -lt "$jobs" ]; do
    [ -e "$SHELLSPEC_JOBDIR/$i.status" ] || continue
    cat "$SHELLSPEC_JOBDIR/$i.stdout"
    cat "$SHELLSPEC_JOBDIR/$i.stderr" >&2
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
  find_specfiles specfile "$@"

  callback() { worker "$1" & }
  sequence callback 0 $(($SHELLSPEC_JOBS-1))

  reduce &

  wait
}
