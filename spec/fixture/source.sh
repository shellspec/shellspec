#shellcheck shell=sh disable=SC2016

if [ "${__SOURCED__+x}" ]; then
  echo "$__SOURCED__"
fi

IFS=:
if [ $# -gt 0 ]; then
  echo "$*"
fi
