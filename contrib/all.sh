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
  [ ${1:+x} ] || return 1; p=$1; until [ "${p%/}" = "$p" ]; do p=${p%/}; done
  [ -e "$p" ] && p=$1; [ -d "$1" ] && p=$p/; set 10 "$PWD" "${OLDPWD:-}"
  CDPATH="" cd -L "$2" && while [ "$1" -gt 0 ]; do set "$1" "$2" "$3" "${p%/*}"
    [ "$p" = "$4" ] || { CDPATH="" cd -L "${4:-/}" || break; p=${p##*/}; }
    [ ! -L "$p" ] && p=${PWD%/}${p:+/}$p && set "$@" "${p:-/}" && break
    set $(($1-1)) "$2" "$3" "$p"; p=$(ls -dl "$p") || break; p=${p#*" $4 -> "}
  done 2>/dev/null; cd -L "$2" && OLDPWD=$3 && [ ${5+x} ] && printf '%s\n' "$5"
}

each_shells() {
    callback=$1 IFS=,
    shift
    for shell in $TARGET; do
      shell_path='' real_path=''
      # shellcheck disable=SC2230
      shell_path=$(which "${shell%% *}" 2>/dev/null) || shell_path=''
      [ -L "${shell_path%% *}" ] && real_path=$(readlinkf "${shell_path%% *}")
      $callback "$@"
    done
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
    echo "$shell" "$@"
    echo "--------------------------------------------------"
    eval "SH=\$shell $shell \"\$@\""
  else
    echo "--------------------------------------------------"
    echo "$shell : Skip, shell not found"
    echo "--------------------------------------------------"
    echo
  fi
}

uname -a
echo "=================================================="
( each_shells info )
echo "=================================================="
if [ $# -gt 0 ]; then
  ( each_shells run "$@" )
fi
