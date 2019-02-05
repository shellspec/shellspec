#!/bin/sh

# Run in all supported shells

# This script is for development purposes.
# It provide as is, do not any support.
# It may change without notice.

# Example of use
#   contrib/all.sh
#   contrib/all.sh shellspec sample/addition_spec.sh
#   contrib/all.sh -c 'echo ok'

set -eu

[ $# -eq 0 ] && set -- ./shellspec

for shell in dash bash zsh ksh mksh yash posh 'busybox ash'; do
  echo "[$shell]"
  if which "${shell%% *}" > /dev/null; then
    $shell "$@" &&:
  else
    echo "Skip, shell not found"
  fi
  echo
done
