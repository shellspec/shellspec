#!/bin/sh

if [ "$1" = "shellspec" ]; then
  sudo shellspec --task fixture:stat:prepare
fi

"$@"
