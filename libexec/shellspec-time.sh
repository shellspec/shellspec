#!/bin/sh
#shellcheck disable=SC2004

"$SHELLSPEC_TRAP" : INT

if [ "$BASH_VERSION" ] || [ "$KSH_VERSION" ]; then
  time -p "$@"
  exit $?
fi

set -eu

read -r sec_start millisec_start <<HERE
$(date +"%s %2N")
HERE

case $millisec_start in (*[!0-9]*)
  millisec_start=0
esac

status=0

if [ $# -gt 0 ]; then
  "$@" &&:
  status=$?
fi

read -r sec_end millisec_end <<HERE
$(date +"%s %2N")
HERE

case $millisec_end in (*[!0-9]*)
  millisec_end=0
esac

sec=$(($sec_end - $sec_start))
millisec=$((1$millisec_end - 1$millisec_start))
if [ $millisec -lt 0 ]; then
  millisec=$(($millisec + 100))
  sec=$(($sec - 1))
fi
[ $millisec -lt 10 ] && millisec="0$millisec"

echo "real $sec.$millisec" >&2

exit $status
