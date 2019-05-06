#shellcheck shell=sh disable=SC2004

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"
use constants

# $1: prefix, $2: filename
read_time_log() {
  [ -r "$2" ] || return 0
  # shellcheck disable=SC2034
  while read -r time_log_name time_log_value; do
    case $time_log_name in (real|user|sys) ;; (*) continue; esac
    case $time_log_value in (*[!0-9.]*) continue; esac
    eval "$1_${time_log_name}=\"\$time_log_value\""
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

field_description() {
  _description=${field_description:-}
  replace _description "$VT" " "
  putsn "$_description"
}
