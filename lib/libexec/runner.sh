#shellcheck shell=sh disable=SC2004

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"
use signal

mktempdir() {
  (umask 0077; mkdir "$1"; chmod 0700 "$1")
}

rmtempdir() {
  rm -rf "$1"
}

read_pid_file() {
  eval "$1=''"
  set -- "$1" "$2" "${3:-999999999}"
  while [ ! -e "$2" ] && [ "$3" -gt 0 ]; do
    set -- "$1" "$2" "$(($3 - 1))"
    sleep 0
  done
  if [ -e "$2" ]; then
    eval "read -r $1 < \"$2\""
  fi
}

sleep_wait() {
  case $1 in
    *[!0-9]*) timeout=999999999 ;;
    *) timeout=$1; shift
  esac
  while "$@"; do
    [ "$timeout" -gt 0 ] || return 1
    sleep 0
    timeout=$(($timeout - 1))
  done
}
