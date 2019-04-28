#!/bin/sh

# Run in all shells

# This script is for development purposes.
# It provide as is, do not any support.
# It may change without notice.

# Example of use
#   contrib/all.sh
#   contrib/all.sh shellspec sample/addition_spec.sh
#   contrib/all.sh -c 'echo ok'

set -eu

: "${TARGET:=sh,ash,dash,bash,zsh,pdksh,ksh,ksh93,mksh,oksh,yash,posh,busybox ash}"

readlinkf() {
  p=$1
  while [ -L "$p" ]; do
    case $p in (*/*) cd "${p%/*}"; p=${p##*/}; esac
    l=$(ls -dl "$p") && p=${l#*"$p -> "}
  done
  case $p in (*/*) cd "${p%/*}"; p=${p##*/}; esac
  printf '%s\n' "$PWD/$p"
}

each_shells() {
  (
    callback=$1 IFS=,
    shift
    for shell in $TARGET; do
      shell_path='' real_path=''
      shell_path=$(which "${shell%% *}" 2>/dev/null) || shell_path=''
      [ -L "${shell_path%% *}" ] && real_path=$(readlinkf "${shell_path%% *}")
      $callback "$@"
    done
  )
}

info() {
  info=$shell_path
  [ "$info" ] && info="$info${real_path:+ -> }$real_path"
  printf '%8s : %s\n' "${shell%% *}" "${info:-----}"
}

run() {
  if [ "$shell_path" ]; then
    echo "--------------------------------------------------"
    echo "$shell : $shell_path${real_path:+ -> }$real_path"
    echo "$shell $@"
    echo "--------------------------------------------------"
    eval SH=\$shell $shell "$@"
  else
    echo "--------------------------------------------------"
    echo "$shell : Skip, shell not found"
    echo "--------------------------------------------------"
    echo
  fi
}

uname -a
echo "=================================================="
each_shells info
echo "=================================================="
if [ $# -gt 0 ]; then
  each_shells run "$@"
fi
