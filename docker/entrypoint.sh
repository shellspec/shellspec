#!/bin/sh

echo "--no-banner" > /shellspec/.shellspec-local
$(which sudo) mkdir -p /usr/local/bin
$(which sudo) ln -s $PWD/shellspec /usr/local/bin/shellspec

if [ "$1" = "shellspec" ]; then
  $(which sudo) $(which shellspec) --task fixture:stat:prepare
fi

"$@"
