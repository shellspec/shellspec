#shellcheck shell=sh disable=SC2004

: "${field_type:-} ${field_fail:-} ${field_specfile:-} ${field_lineno_range:-}"

create_buffers failures

failures_each() {
  case $field_type in (result)
    [ "$field_fail" ] || return 0
    failures '=' "./$field_specfile:${field_lineno_range%-*}:$(field_description)${LF}"
  esac
}

failures_output() {
  failures '>>>'
}
