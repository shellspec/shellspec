#!/bin/sh

if [ "$1" = "shellspec" ]; then
  (
    export SUDO_GID=$(id -g user) SUDO_UID=$(id -u user)
    su-exec root shellspec --task fixture:stat:prepare
  )
fi

"$@"
