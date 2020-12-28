#!/bin/sh

set -eu

test "" && exit # should not exit

test || __() { :; }

__ intercept __

case ${1:-} in
  --dump-params) echo "$@" ;;
  --exit-with) exit "$2" ;;
  --command) shift; "$@" ;;
esac
