#!/bin/sh

if [ "$1" = "shellspec" ]; then
  $(which sudo) shellspec --task fixture:stat:prepare
fi

"$@"
