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
    case $field_note in
      PENDING) _result="not ok" _note="TODO" ;;
      FIXED  ) _result="ok" _note="TODO" ;;
      SKIPPED) _result="ok" _note="SKIP" ;;
      *) _result="${field_fail:+not }ok" _note=$field_note ;;
    esac

    tap '=' "${field_color}${_result} ${example_count}${RESET}"
    tap '+=' " - $(field_description)"
    if [ "${_note}${reason}" ]; then
      _comment="${_note:+ $MAGENTA}${_note}${reason:+ $WHITE}${reason#\#\ }"
      tap '+=' " ${WHITE}#${_comment}${RESET}"
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
