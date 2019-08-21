#!/bin/sh

if [ "$1" = "shellspec" ]; then
  sudo shellspec --task fixture:stat:prepare
fi

[ "$(id -u)" -eq 0 ] && set -- su user "$@"

"$@"
