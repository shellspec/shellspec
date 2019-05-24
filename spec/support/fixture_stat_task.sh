#shellcheck shell=sh

# without root privileges
# $ shellspec --task fixture:stat:prepare
#
# with root privileges
# $ sudo $(which shellspec) --task fixture:stat:prepare
#
# cleanup
# $ shellspec --task fixture:stat:cleanup


set -eu

task "fixture:stat:prepare" "Prepare file stat tests"
task "fixture:stat:cleanup" "Cleanup file stat tests"

fixture="$SHELLSPEC_SPECDIR/fixture"
owner=${SUDO_UID:-$(id -u)}:${SUDO_GID:-$(id -g)}

symlink() {
  ln -s ../file "$1" 2>/dev/null
  if [ -L "$1" ]; then
    chown -h "$owner" "$1"
    return 0
  fi
  rm "$1"
  return 1
}

pipe() {
  mkfifo "$1" 2>/dev/null
  if [ -p "$1" ]; then
    chown "$owner" "$1"
    return 0
  fi
  rm "$1"
  return 1
}

create_socket_file() {
  (
    command nc -lU "$1" &
    sleep 1
    kill $!
    wait $!
  )
  [ -S "$1" ] && return 0
  rm "$1"
  return 1
}

socket() {
  if create_socket_file "$1" 2>/dev/null; then
    chown "$owner" "$1"
    return 0
  fi
  return 1
}

file() {
  echo "${4:-}" > "$1"
  chown "$owner" "$1"
  chmod "$2" "$1"
  case $(ls -dl "$1") in
    $3*) return 0
  esac
  rm "$1"
  return 1
}

device() {
  mknod "$@" 2>/dev/null
  if [ -e "$1" ]; then
    chown "$owner" "$1" 2>/dev/null && return 0
    rm -f "$1"
  fi
  return 1
}

create() {
  [ -e "$2" ] && rm -f "$2"

  if "$@"; then
    echo "[created] '$2'"
  else
    echo "[failure] '$2'"
  fi
}

delete() {
  if [ -e "$2" ]; then
    if rm -f "$2"; then
      echo "[deleted] '$2'"
    else
    echo "[failure] '$2'"
    fi
  fi
}

fixture_stat_files() {
  "$1" symlink "$fixture/stat/symlink"
  "$1" pipe    "$fixture/stat/pipe"
  "$1" socket  "$fixture/stat/socket"
  "$1" file    "$fixture/stat/readable"         a=,u+r "-r??"
  "$1" file    "$fixture/stat/writable"         a=,u+w "-?w?"
  "$1" file    "$fixture/stat/executable"       a=,u+x "-??x"     "#!/bin/sh"
  "$1" file    "$fixture/stat/no-permission"    a=     "----"
  "$1" file    "$fixture/stat/setuid"           a=,u+s "---S"
  "$1" file    "$fixture/stat/setgid"           a=,g+s "------S"
  "$1" device  "$fixture/stat/block-device"     b 0 0 # Unnamed devices
  "$1" device  "$fixture/stat/charactor-device" c 1 3 # Null device
}

fixture_stat_prepare_task() {
  fixture_stat_files create
}

fixture_stat_cleanup_task() {
  fixture_stat_files delete
}
