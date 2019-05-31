#shellcheck shell=sh disable=SC2004

: "${count_examples:-} ${aborted:-} ${example_count:-} ${field_type:-}"
: "${field_note:-} ${field_fail:-} ${field_description:-} ${field_message:-}"

create_buffers tap

tap_initialize() {
  count "$@"
}

tap_begin() {
  tap '=' "1..${count_examples}${LF}"
}

tap_each() {
  case $field_type in (result)
    tap '=' "${field_fail:+not }ok $example_count" \
      "- $(field_description)${field_note:+ # }$field_note${LF}"
  esac
}

tap_end() {
  [ "$aborted" ] || return 0
  tap '=' "not ok $(($count_examples + 1)) - aborted by unexpected error${LF}"
}

tap_output() {
  tap '>>>'
}
