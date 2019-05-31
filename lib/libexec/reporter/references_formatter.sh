#shellcheck shell=sh

: "${example_index:-} ${example_count_per_file:-}"
: "${field_type:-} ${field_specfile:-} ${field_range:-} ${field_focused:-}"
: "${field_color:-} ${field_fail:-} ${field_note:-} ${field_example_count:-}"

create_buffers references_notable references_failure

references_each() {
  case $field_type in
    result)
      [ -z "$example_index" ] && [ "$field_focused" != "focus" ] && return 0

      set -- "${field_color}shellspec" \
        "$field_specfile:${field_range%-*}${RESET}" \
        "$CYAN# ${example_index:--})" \
        "$(field_description) ${field_note}${RESET}"

      # shellcheck disable=SC2145
      [ "$field_focused" = "focus" ] && set -- "${UNDERLINE}$@"

      if [ "$field_fail" ]; then
        references_failure '|=' "${BOLD}Failure examples:" \
          "(Listed here affect your suite's status)${RESET}${LF}${LF}"
        references_failure '+=' "${*:-}${LF}"
      else
        references_notable '|=' "${BOLD}Notable examples:" \
          "(Listed here do not affect your suite's status)${RESET}${LF}${LF}"
        references_notable '+=' "${*:-}${LF}"
      fi
      ;;
    end)
      [ "$example_count_per_file" -eq "$field_example_count" ] && return 0

      set -- "${RED}shellspec $field_specfile${RESET}" \
        "$CYAN# expected $field_example_count examples," \
        "but only ran $example_count_per_file examples${RESET}"

      references_failure '|=' "${BOLD}Failure examples:" \
        "(Listed here affect your suite's status)${RESET}${LF}${LF}"
      references_failure '+=' "${*:-}${LF}"
      ;;
  esac
}

references_end() {
  references_notable '!?' || references_notable '+=' "$LF"
  references_failure '!?' || references_failure '+=' "$LF"
 }

references_output() {
  case $1 in (end)
    references_notable '>>>'
    references_failure '>>>'
  esac
}
