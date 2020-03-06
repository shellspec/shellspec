#shellcheck shell=sh disable=SC2004

: "${field_type:-} ${field_tag:-} ${field_fail:-}"
: "${field_note:-} ${field_specfile:-} ${field_lineno_range:-}"
: "${temporary_skip:-}"

create_buffers failures

failures_each() {
  case $field_type in (result)
    [ "$field_tag" = "succeeded" ] && return 0
    [ "$field_tag" = "skipped" ] && [ "$temporary_skip" -eq 0 ] && return 0
    failures '=' "./$field_specfile:${field_lineno_range%-*}:${field_note}"
    failures '+=' ":$(field_description)${LF}"
  esac
}

failures_output() {
  failures '>>>'
}
