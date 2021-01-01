#shellcheck shell=sh disable=SC2004

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"
use is_empty_directory resolve_module_path module_exists

mktempdir() {
  ( umask 0077
    mkdir "$1"
    # Workaround for busybox < 1.20.0 mkdir: fix permissions on 64-bit platforms
    # https://bugs.busybox.net/show_bug.cgi?id=4814
    [ -u "$1" ] && chmod 0700 "$1"
    is_empty_directory "$1"
  ) && return 0
  abort "Somehow any files are exists in the temporary directory" \
    "just created. Abort to avoid security risk."
}

rmtempdir() {
  rm -rf "$1"
}

read_pid_file() {
  eval "$1=''"
  set -- "$1" "$2" "${3:-999999999}"
  while [ ! -e "$2" ] && [ "$3" -gt 0 ]; do
    set -- "$1" "$2" "$(($3 - 1))"
    nap
  done
  if [ -e "$2" ]; then
    eval "read -r $1 < \"$2\""
  fi
}
