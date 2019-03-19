#shellcheck shell=sh disable=SC2004

shellspec_constants
shellspec_proxy proxy shellspec_proxy
shellspec_proxy import shellspec_import
shellspec_proxy putsn shellspec_putsn
shellspec_proxy puts shellspec_puts
shellspec_proxy padding shellspec_padding
shellspec_proxy each shellspec_each

shellspec_import posix
shellspec_proxy unixtime shellspec_unixtime

reset_params() {
  shellspec_reset_params "$@"
  eval 'RESET_PARAMS=$SHELLSPEC_RESET_PARAMS'
}

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
