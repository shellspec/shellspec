#shellcheck shell=sh disable=SC2154

tap_failures='' tap_plan=0

create_buffers tap

require_formatters profiler

tap_initialize() {
  count_examples tap_plan "$@"
}

tap_begin() {
  tap '=' "${WHITE}1..${tap_plan}${LF}"
}

tap_each() {
  _color=$field_color _failure_message=''
  case $field_type in
    statement)
      case $field_tag in (bad | warn)
        _failure_line="in specfile $field_specfile, line $field_lineno"
        [ "$field_note" ] && _failure_line="$_failure_line, $field_note"
        tap_failures="${tap_failures}($_failure_line)${LF}"
        if [ "$field_evaluation" ]; then
          tap_failures="${tap_failures}${field_evaluation}${LF}"
        fi
        tap_failures="${tap_failures}${field_message}${LF}${LF}"
        wrap _failure_message "${field_failure_message}" "  "
        if [ "$_failure_message" ]; then
          tap_failures="${tap_failures}${_failure_message}${LF}"
        fi
      esac ;;
    result)
      case $field_note in
        PENDING) _result="not ok" _note="TODO" ;;
        FIXED  ) _result="ok" _note="TODO" ;;
        SKIPPED) _result="ok" _note="SKIP" ;;
        *) _result="${field_fail:+not }ok" _note=$field_note ;;
      esac
      _description=$(field_description)
      replace_all _description "$LF" ""
      replace_all _description "$CR" ""
      tap '=' "${_color}${_result} ${example_count}${RESET} - $_description"
      if [ "${_note}${reason}" ]; then
        _comment="${_note:+ $MAGENTA}${_note}${reason:+ $WHITE}${reason#\#\ }"
        tap '+=' " ${WHITE}#${_comment}${RESET}"
      fi
      tap '+=' "${LF}"
      if [ "$tap_failures" ]; then
        wrap _failures "$tap_failures" "${_color}# " "${RESET}"
        tap '+=' "$_failures"
        tap_failures=''
      fi ;;
    error)
      _failure_line="in specfile $field_specfile, line $field_lineno"
      [ "$field_note" ] && _failure_line="$_failure_line, $field_note"
      wrap _failure_message "${field_failure_message}${LF}" "  "
      _failures="($_failure_line)${LF}${field_message}${LF}${LF}"
      wrap _failures "${_failures}${_failure_message}" "${_color}# " "${RESET}"
      tap '=' "${_failures}"
  esac
}

tap_end() {
  _bailout=''
  [ "$error_count" ] && _bailout="Some errors occurred."
  [ "$aborted" ] && _bailout="Aborted by unexpected errors."

  [ "$_bailout" ] || return 0
  tap '=' "${BOLD}${RED}Bail out!${RESET} ${_bailout}${LF}"
}

tap_output() {
  tap '>>>'
  output "$1" profiler
}
