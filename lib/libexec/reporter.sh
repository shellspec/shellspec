#shellcheck shell=sh disable=SC2004

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"
use constants

# $1: prefix, $2: filename
read_log() {
  [ -r "$2" ] || return 0
  # shellcheck disable=SC2034
  while read -r read_log_name read_log_value; do
    eval "$1_${read_log_name}=\"\$read_log_value\""
  done < "$2"
}

buffer() {
  while [ $# -gt 0 ]; do
    eval "
      $1_buffer=''
      $1_is_empty() { [ -z \"\$$1_buffer\" ]; }
      $1_set_if_empty() { if $1_is_empty; then $1_append \"\$@\"; fi; }
      $1_append() { $1_buffer=\$$1_buffer\${*:-}\${LF}; }
      $1_flush() {
        if ! $1_is_empty; then putsn \"\$$1_buffer\"; $1_buffer=''; fi
      }
    "
    shift
  done
}
