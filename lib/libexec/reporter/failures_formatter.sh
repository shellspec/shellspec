#shellcheck shell=sh disable=SC2154

create_buffers failures

failures_each() {
  case $field_type in
    result)
      [ "$field_tag" = "succeeded" ] && return 0
      [ "$field_tag" = "skipped" ] && [ "$temporary_skip" -eq 0 ] && return 0
      failures '=' "./${field_specfile}:${field_lineno_range%-*}:${field_note}"
      failures '+=' ":$(field_description)${LF}"
      ;;
    error)
      failures '=' "./${field_specfile}:${field_lineno}:${field_note}"
      failures '+=' ":${field_message}${LF}"
  esac
}

failures_output() {
  failures '>>>'
}
