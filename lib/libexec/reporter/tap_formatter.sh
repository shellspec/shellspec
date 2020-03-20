#shellcheck shell=sh disable=SC2004

: "${count_examples:-} ${aborted:-} ${example_count:-} ${reason:-}"
: "${field_color:-} ${field_type:-} ${field_note:-} ${field_fail:-}"
: "${field_description:-} ${field_message:-}"

create_buffers tap

tap_initialize() {
  count "$@"
}

tap_begin() {
  tap '=' "${WHITE}1..${count_examples}${LF}"
}

tap_each() {
  case $field_type in (result)
    tap '=' "${field_color}${field_fail:+not }ok $example_count${RESET}" \
      "- $(field_description)"
    if [ "${field_note}${reason}" ]; then
      tap '+=' " ${WHITE}#"
      tap '+=' "${field_note:+ ${MAGENTA}}$field_note"
      tap '+=' "${reason:+ ${WHITE}}$reason"
      tap '+=' "${RESET}"
    fi
    tap '+=' "${LF}"
  esac
}

tap_end() {
  [ "$aborted" ] || return 0
  tap '=' "${RED}not ok $(($count_examples + 1))${RESET}" \
    "- aborted by unexpected error${LF}"
}

tap_output() {
  tap '>>>'
}
