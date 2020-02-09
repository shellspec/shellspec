#!/bin/sh

if [ "$1" = "shellspec" ]; then
  (
    export SUDO_GID=$(id -g) SUDO_UID=$(id -u)
    su-exec root shellspec --task fixture:stat:prepare
  )
fi

"$@"
