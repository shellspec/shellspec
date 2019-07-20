#!/bin/sh
#shellcheck disable=SC2004

# Workaround. An unknown error has occurred in zsh (confirmed 4.3.1, 5.0.2).
#
#   /shellspec/libexec/shellspec-profiler.sh:48: command not found: 123
#
# The 123 is last word(?) of handler. zsh tries to call 123 somehow. The number
# changes with the timing. Once this error occurs profiler be not able to recive
# the signal.

#shellcheck disable=SC2123
PATH='' # To avoid unexpected command execution, for example 123 command.

handler() {
  eval "counter${index}=$counter index=$(($index + 1))"
}

terminate() {
  i=0 start='' end=''
  while [ "$i" -lt "$index" ]; do
    eval "start=\$counter${i} end=\${counter$(($i + 1)):-}"
    [ "$end" ] || break
    echo "$(($end - $start))" >> "$SHELLSPEC_PROFILER_LOG"
    i=$(($i + 2))
  done
  finished
  exit
}

write_pid() {
  echo "$1" > "$SHELLSPEC_TMPBASE/profiler.pid"
}

finished() {
  : > "$SHELLSPEC_TMPBASE/profiler.done"
}

: > "$SHELLSPEC_PROFILER_LOG"

if ! ( trap - USR1 && trap - TERM ) 2>/dev/null; then
  write_pid ''
  exit 1
fi

trap handler USR1
trap terminate TERM
trap finished EXIT

index=0 counter=0
write_pid "$$"

while :; do
  while :; do
    counter=$(($counter + 1))
  done
  # echo "[profiler] an unknown error has occurred (zsh bug?)" >&2
done

echo "[profiler] aborted" >&2
exit 1
