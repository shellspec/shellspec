#!/bin/sh
#shellcheck disable=SC2004

set -eu

: > "$SHELLSPEC_PROFILER_LOG"

index=0 counter=0

: > "$SHELLSPEC_PROFILER_SIGNAL"

while [ -e "$SHELLSPEC_PROFILER_SIGNAL" ]; do
  if [ -s "$SHELLSPEC_PROFILER_SIGNAL" ]; then
    eval "counter${index}=$counter index=$(($index + 1))"
    : > "$SHELLSPEC_PROFILER_SIGNAL"
  fi
  counter=$(($counter + 1))
done

i=0 start='' end=''
while [ "$i" -lt "$index" ]; do
  eval "start=\$counter${i} end=\${counter$(($i + 1)):-}"
  [ "$end" ] || break
  echo "$(($end - $start))" >> "$SHELLSPEC_PROFILER_LOG"
  i=$(($i + 2))
done
echo "$counter" > "$SHELLSPEC_PROFILER_LOG.total"
: > "$SHELLSPEC_TMPBASE/profiler.done"
