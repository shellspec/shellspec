#shellcheck shell=sh

: "${example_index:-} ${detail_index:-} ${field_color:-} ${field_type:-}"
: "${field_specfile:-} ${field_lineno:-} ${field_tag:-} ${field_note:-}"
: "${field_evaluation:-} ${field_message:-} ${field_failure_message:-}"

conclusion_evaluation=''
create_buffers conclusion

conclusion_each() {
  _label='' _indent='' _message='' _text=''

  [ "$field_type" = example ] && conclusion_evaluation=''
  [ "$field_type" = statement ] || return 0
  [ "$field_tag" = evaluation ] && conclusion_evaluation=$field_evaluation
  case $field_tag in (evaluation|good) return 0; esac
  [ "$example_index" ] || return 0

  conclusion '|=' "Examples:${LF}"
  _label="  $example_index) "
  padding _indent ' ' ${#_label}
  if [ "$detail_index" -eq 1 ]; then
    conclusion '+=' "${WHITE}${_label}$(field_description)${RESET}${LF}"
  fi

  if [ "$conclusion_evaluation" ]; then
    conclusion '+=' "${BOLD}${CYAN}${_indent}${conclusion_evaluation}${RESET}"
    conclusion '+=' "${LF}${LF}"
    conclusion_evaluation=''
  fi

  _label="${_indent}${example_index}.${detail_index}) "
  padding _indent ' ' ${#_label}

  _message="${field_note:+[}$field_note${field_note:+] }$field_message"
  conclusion '+=' "${_label}${field_color}${_message}${RESET}${LF}${LF}"

  case $field_tag in (warn|bad)
    _message=$field_failure_message _text=''
    while [ "$_text" != "$_message" ]; do
      _text=${_message%%${LF}*}
      _message=${_message#*${LF}}
      conclusion '+=' "  ${_indent}${field_color}${_text}${RESET}${LF}"
    done
  esac

  conclusion '+=' "${_indent}${CYAN}#" \
    "${field_specfile}:${field_lineno}${RESET}${LF}${LF}"
}

conclusion_end() {
  conclusion '<|>'
}

conclusion_output() {
  case $1 in (end)
    conclusion '>>>'
  esac
}
