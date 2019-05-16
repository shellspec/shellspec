#shellcheck shell=sh disable=SC2004,SC2034

: "${example_index:-} ${detail_index:-} ${field_color:-}"
: "${field_type:-} ${field_specfile:-} ${field_tag:-} ${field_lineno:-}"
: "${field_evaluation:-} ${field_message:-} ${field_failure_message:-}"

use padding
buffer conclusion

conclusion_format() {
  _label='' _indent='' _message='' _text=''

  [ "$field_type" = "statement" ] || return 0
  case $field_tag in (evaluation|good) return 0; esac
  [ "$example_index" ] || return 0

  conclusion set_if_empty "${LF}Examples:${LF}"
  _label="  $example_index) "
  padding _indent ' ' ${#_label}
  if [ "$detail_index" -eq 1 ]; then
    conclusion append "${WHITE}${_label}$(field_description)${RESET}"
    if [ "$field_evaluation" ]; then
      conclusion append "${BOLD}${CYAN}${_indent}${field_evaluation}${RESET}"
      conclusion append
    fi
  fi

  _label="${_indent}${example_index}.${detail_index}) "
  padding _indent ' ' ${#_label}

  case $field_tag in
    bad ) _message="Failure $field_message" ;;
    warn) _message="Warning $field_message" ;;
    *   ) _message=$field_message ;;
  esac
  conclusion append "${_label}${field_color}${_message}${RESET}${LF}"

  case $field_tag in (warn|bad)
    _message=$field_failure_message _text=''
    while [ "$_text" != "$_message" ]; do
      _text=${_message%%${LF}*}
      _message=${_message#*${LF}}
      conclusion append "  ${_indent}${field_color}${_text}${RESET}"
    done
  esac

  conclusion append "${_indent}${CYAN}#" \
    "${field_specfile}:${field_lineno}${RESET}${LF}"
}

conclusion_output() {
  case $1 in
    end) conclusion output ;;
  esac
}
