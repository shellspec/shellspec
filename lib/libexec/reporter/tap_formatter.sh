#shellcheck shell=sh disable=SC2004

: "${count_examples:-} ${aborted:-} ${example_count:-} ${reason:-}"
: "${field_color:-} ${field_type:-} ${field_note:-} ${field_fail:-}"
: "${field_description:-} ${field_message:-} ${field_tag:-} ${field_lineno:-}"
: "${field_specfile:-} ${field_evaluation:-} ${field_failure_message:-}"

tap_failures=''
create_buffers tap

tap_initialize() {
  count "$@"
}

tap_begin() {
  tap '=' "${WHITE}1..${count_examples}${LF}"
}

tap_each() {
  _color=$field_color
  case $field_type in
    statement)
      case $field_tag in (bad | warn)
        _failure_line="in specfile $field_specfile, line $field_lineno"
        [ "${field_note}" ] && _failure_line="$_failure_line, $field_note"
        tap_failures="${tap_failures}${_color}($_failure_line)${LF}"
        tap_failures="${tap_failures}${_color}${field_evaluation}${LF}"
        tap_failures="${tap_failures}${_color}${field_message}${LF}"
        tap_failures="${tap_failures}${_color}${field_failure_message}${LF}"
      esac ;;
    result)
      case $field_note in
        PENDING) _result="not ok" _note="TODO" ;;
        FIXED  ) _result="ok" _note="TODO" ;;
        SKIPPED) _result="ok" _note="SKIP" ;;
        *) _result="${field_fail:+not }ok" _note=$field_note ;;
      esac
      tap '=' "${_color}${_result} ${example_count}${RESET}"
      tap '+=' " - $(field_description)"
      if [ "${_note}${reason}" ]; then
        _comment="${_note:+ $MAGENTA}${_note}${reason:+ $WHITE}${reason#\#\ }"
        tap '+=' " ${WHITE}#${_comment}${RESET}"
      fi
      tap '+=' "${LF}"
      if [ "$tap_failures" ]; then
        set -- "$tap_failures" ""
        while [ "$1" ]; do
          set -- "${1#*"${LF}"}" "$2${_color}# ${1%%"$LF"*}${RESET}${LF}"
        done
        tap '+=' "$2"
        tap_failures=''
      fi
  esac
}

tap_end() {
  [ "$aborted" ] || return 0
  tap '=' "${BOLD}${RED}Bail out!${RESET} Aborted by unexpected error.${LF}"
}

tap_output() {
  tap '>>>'
}
