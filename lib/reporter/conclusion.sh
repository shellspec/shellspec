#shellcheck shell=sh disable=SC2004,SC2034

: "${example_index:-} ${detail_index:-}"
: "${field_type:-} ${field_specfile:-} ${field_tag:-}"
: "${field_lineno:-} ${field_color:-}"

use padding
buffer conclusion

conclusion_format() {
  [ "$field_type" = "statement" ] || return 0
  case $field_tag in (evaluation|good) return 0; esac
  [ "$example_index" ] || return 0

  conclusion_set_if_empty "${LF}Examples:${LF}"
  label="  $example_index) " indent=''
  padding indent ' ' ${#label}
  if [ "$detail_index" -eq 1 ]; then
    conclusion_append "${WHITE}${label}$(field_description)${RESET}"
    if [ "${field_evaluation:-}" ]; then
      conclusion_append "${BOLD}${CYAN}${indent}${field_evaluation:-}${RESET}"
      conclusion_append
    fi
  fi

  label="${indent}${example_index}.${detail_index}) "
  indent=''
  padding indent ' ' ${#label}

  case $field_tag in
    bad ) tag='Failure' ;;
    warn) tag='Warning' ;;
    *   ) tag='' ;;
  esac

  message="${tag}${tag:+: }${field_message:-}"
  conclusion_append "${label}${field_color}${message}${RESET}"

  message=${LF}${field_failure_message:-} text=''
  while [ "$text" != "$message" ]; do
    text=${message%%${LF}*}
    message=${message#*${LF}}
    conclusion_append "  ${indent}${field_color}${text}${RESET}"
  done

  conclusion_append "${indent}${CYAN}#" \
    "${field_specfile}:${field_lineno}${RESET}${LF}"
}

conclusion_end() {
  conclusion_flush
}
