#!/bin/sh

set -eu

# shellcheck source=lib/libexec/executor.sh
. "${SHELLSPEC_LIB:-./lib}/libexec/executor.sh"

SHELLSPEC_JOBDIR="$SHELLSPEC_TMPBASE/jobs"

translator() {
  translator="$SHELLSPEC_LIBEXEC/shellspec-translator.sh"
  # shellcheck disable=SC2086
  eval "$SHELLSPEC_SHELL \"$translator\" \"\$@\""
}

shell() {
  # shellcheck disable=SC2086
  $SHELLSPEC_SHELL
}

mkdir $SHELLSPEC_JOBDIR

jobs=0
each_file() {
  ! is_specfile "$1" && return 0
  putsn "$1" > "$SHELLSPEC_JOBDIR/$jobs.job"
  jobs=$((jobs+1))
}
find_files each_file "$@"

worker() {
  i=0
  while [ $i -lt $jobs ]; do
    if mv "$SHELLSPEC_JOBDIR/$i.job" "$SHELLSPEC_JOBDIR/$i.job#" 2>/dev/null; then
      IFS= read -r specfile < "$SHELLSPEC_JOBDIR/$i.job#"
      #echo "$1: $SHELLSPEC_JOBDIR/$i.job $specfile" >/dev/tty1
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

i=0 workers="$SHELLSPEC_JOBS"
while [ $i -lt $workers ]; do
  worker "$i" &
  i=$((i+1))
done

reduce() {
  i=0
  while [ $i -lt $jobs ]; do
    if [ ! -e "$SHELLSPEC_JOBDIR/$i.status" ]; then
      continue
    fi
    #echo $SHELLSPEC_JOBDIR/$i >/dev/tty1
    cat "$SHELLSPEC_JOBDIR/$i.stdout"
    cat "$SHELLSPEC_JOBDIR/$i.stderr" >&2
    IFS= read -r status < "$SHELLSPEC_JOBDIR/$i.status"
    [ "$status" -ne 0 ] && exit "$status"
    i=$((i+1))
  done
}
reduce &

wait
