#!/bin/sh

set -eu

# shellcheck source=lib/libexec/executor.sh
. "${SHELLSPEC_LIB:-./lib}/libexec/executor.sh"

SHELLSPEC_JOBDIR="$SHELLSPEC_TMPBASE/jobs"

mkdir "$SHELLSPEC_JOBDIR"

jobs=0
specfile() {
  putsn "$1" > "$SHELLSPEC_JOBDIR/$jobs.job"
  jobs=$((jobs+1))
}
find_specfiles specfile "$@"

worker() {
  i=0
  while [ $i -lt $jobs ]; do
    if mv "$SHELLSPEC_JOBDIR/$i.job" "$SHELLSPEC_JOBDIR/$i.job#" 2>/dev/null; then
      IFS= read -r specfile < "$SHELLSPEC_JOBDIR/$i.job#"
      {
        if [ $i -eq 0 ]; then
          translator --metadata "$specfile" | shell
        else
          translator "$specfile" | shell
        fi
      } > "$SHELLSPEC_JOBDIR/$i.stdout#" 2> "$SHELLSPEC_JOBDIR/$i.stderr#" &&:
      echo "$?" > "$SHELLSPEC_JOBDIR/$i.status#"
      for ext in stdout stderr status; do
        mv "$SHELLSPEC_JOBDIR/$i.$ext#" "$SHELLSPEC_JOBDIR/$i.$ext"
      done
    fi
    i=$((i+1))
  done
}

i=0
while [ $i -lt "$SHELLSPEC_JOBS" ]; do
  worker "$i" &
  i=$((i+1))
done

reduce() {
  i=0
  while [ $i -lt $jobs ]; do
    [ -e "$SHELLSPEC_JOBDIR/$i.status" ] || continue
    cat "$SHELLSPEC_JOBDIR/$i.stdout"
    cat "$SHELLSPEC_JOBDIR/$i.stderr" >&2
    read -r exit_status < "$SHELLSPEC_JOBDIR/$i.status"
    [ "$exit_status" -ne 0 ] && exit "$exit_status"
    i=$((i+1))
  done
}
reduce &

wait
