#!/bin/sh
#shellcheck disable=SC2004

set -eu

handler() {
  eval "counter${index}=$counter"
  index=$(($index + 1))
}

terminate() {
  i=0 start='' end=''
  while [ $i -lt $index ]; do
    eval "start=\$counter${i} end=\${counter$(($i + 1)):-}"
    [ "$end" ] || break
    echo "$(($end - $start))" >> "$SHELLSPEC_PROFILER_LOG"
    i=$(($i + 2))
  done
  exit
}

trap handler USR1
trap terminate TERM

index=0 counter=0
while :; do
  counter=$(($counter + 1))
done
