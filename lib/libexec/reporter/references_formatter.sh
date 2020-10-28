#shellcheck shell=sh disable=SC2154

create_buffers references_notable references_failure references_fixed

references_each() {
  _affect="(Listed here ${UNDERLINE}affect${RESET} your suite's status)"
  _not_affect="(Listed here do not affect your suite's status)"

  case $field_type in
    result)
      [ -z "$example_index" ] && [ "$field_focused" != "focus" ] && return 0

      set -- "${field_color}shellspec" \
        "${field_specfile}:${field_lineno_range%-*}${RESET}" \
        "$CYAN# ${example_index:--})" \
        "$(field_description) ${field_note}${RESET}"

      # shellcheck disable=SC2145
      [ "$field_focused" = "focus" ] && set -- "${UNDERLINE}$@"

      if [ "$field_tag" = "fixed" ]; then
        references_fixed '|=' "${LF}${BOLD}${GREEN}Fixed examples:" \
          "${RESET}${_affect}${LF}${LF}"
        references_fixed '+=' "${*:-}${LF}"
      elif [ "$field_fail" ]; then
        references_failure '|=' "${LF}${BOLD}${RED}Failure examples / Errors:" \
          "${RESET}${_affect}${LF}${LF}"
        references_failure '+=' "${*:-}${LF}"
      else
        references_notable '|=' "${LF}${BOLD}${YELLOW}Notable examples:" \
          "${RESET}${_not_affect}${LF}${LF}"
        references_notable '+=' "${*:-}${LF}"
      fi
      ;;
    error)
      set -- "${field_color}shellspec" \
        "${field_specfile}:${field_lineno}${RESET}" \
        "$CYAN# $error_index)" \
        "$field_message ${field_note}${RESET}"
      references_failure '|=' "${LF}${BOLD}${RED}Failure examples / Errors:" \
        "${RESET}${_affect}${LF}${LF}"
      references_failure '+=' "${*:-}${LF}"
      ;;
    end)
      [ "$example_count_per_file" -eq "$field_example_count" ] && return 0

      set -- "${BOLD}${RED}shellspec $field_specfile${RESET}" \
        "$CYAN# expected $field_example_count examples," \
        "but only ran $example_count_per_file examples${RESET}"

      references_failure '|=' "${LF}${BOLD}${RED}Failure examples / Errors:" \
        "${RESET}${_affect}${LF}${LF}"
      references_failure '+=' "${*:-}${LF}"
      ;;
  esac
}

references_end() {
  references_notable '!?' || references_notable '+=' "$LF"
  references_failure '!?' || references_failure '+=' "$LF"
  references_fixed '!?' || references_fixed '+=' "$LF"
 }

references_output() {
  case $1 in (end)
    references_notable '>>>'
    references_failure '>>>'
    references_fixed '>>>'
  esac
}
