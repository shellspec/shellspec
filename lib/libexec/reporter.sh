#shellcheck shell=sh disable=SC2004

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"
use constants proxy import puts putsn padding each reset_params unixtime

# $1: filename $2: timeout
wait_for_log_exists() {
  unixtime start_time
  while [ ! -s "$1" ]; do
    [ "${2:-}" ] || return 1
    unixtime current_time
    # shellcheck disable=SC2154
    [ $(($current_time - $start_time)) -lt "$2" ] || return 1
  done
}

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
