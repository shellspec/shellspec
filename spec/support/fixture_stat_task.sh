#shellcheck shell=sh

set -eu

task "fixture:stat:prepare" "Prepare file stat tests"
task "fixture:stat:cleanup" "Cleanup file stat tests"

fixture="$SHELLSPEC_SPECDIR/fixture"
owner=${SUDO_UID:-$(id -u)}:${SUDO_GID:-$(id -g)}

symlink() { ln -s ../file "$1" && chown -h "$owner" "$1"; }
pipe() { mkfifo "$1" && chown "$owner" "$1"; }
socket() { nc -lU "$1" & sleep 1 && kill $! && chown "$owner" "$1"; }
file() { touch "$1" && chown "$owner" "$1" && chmod "$2" "$1"; }
device() { mknod "$@" && chown "$owner" "$1"; }

create() {
  if [ -e "$2" ]; then
    echo "exist '$2'"
  elif "$@"; then
    echo "created '$2'"
  else
    echo "can not create '$2'"
  fi
}

delete() {
  if [ -e "$2" ]; then
    rm -f "$2"
    echo "deleted '$2'"
  else
    echo "not exist '$2'"
  fi
}

fixture_stat_files() {
  "$1" symlink "$fixture/stat/symlink"
  "$1" pipe    "$fixture/stat/pipe"
  "$1" socket  "$fixture/stat/socket"
  "$1" file    "$fixture/stat/readable"         a=,u+r
  "$1" file    "$fixture/stat/writable"         a=,u+w
  "$1" file    "$fixture/stat/executable"       a=,u+x
  "$1" file    "$fixture/stat/no-permission"    a=
  "$1" file    "$fixture/stat/setgid"           a=,g+s
  "$1" file    "$fixture/stat/setuid"           a=,u+s
  "$1" device  "$fixture/stat/block-device"     b 0 0 # Unnamed devices
  "$1" device  "$fixture/stat/charactor-device" c 1 3 # Null device
}

fixture_stat_prepare_task() {
  fixture_stat_files create
}

fixture_stat_cleanup_task() {
  fixture_stat_files delete
}
