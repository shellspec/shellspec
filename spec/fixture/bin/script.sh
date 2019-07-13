#!/bin/sh

set -eu

#shellcheck disable=SC2034
(__SOURCED__=) && __() { :; }

__ intercept __

case ${1:-} in
  --dump-params) echo "$@" ;;
  --exit-with) exit "$2" ;;
  --command) shift; "$@" ;;
esac
