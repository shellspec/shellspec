#shellcheck shell=sh disable=SC2004,SC2034

: "${example_index:-} ${example_count_per_file:-}"
: "${field_type:-} ${field_specfile:-} ${field_range:-} ${field_focused:-}"
: "${field_color:-} ${field_error:-} ${field_note:-} ${field_example_count:-}"

buffer notable_examples failure_examples

references_format() {
  case $field_type in
    result)
      [ -z "$example_index" ] && [ "$field_focused" != "focus" ] && return 0

      set -- "${field_color}shellspec" \
        "$field_specfile:${field_range%-*}${RESET}" \
        "$CYAN# ${example_index:--}) $(field_description) ${field_note}${RESET}"

      # shellcheck disable=SC2145
      [ "$field_focused" = "focus" ] && set -- "${UNDERLINE}$@"

      if [ "$field_error" ]; then
        failure_examples_set_if_empty "Failure examples:${LF}"
        failure_examples_append "$@"
      else
        notable_examples_set_if_empty "Notable examples:" \
          "(listed here are expected and do not affect your suite's status)$LF"
        notable_examples_append "$@"
      fi
      ;;
    end)
      [ "$example_count_per_file" -eq "$field_example_count" ] && return 0

      set -- "${RED}shellspec $field_specfile${RESET}" \
        "$CYAN# expected $field_example_count examples," \
        "but only ran $example_count_per_file examples${RESET}"

      failure_examples_set_if_empty "Failure examples:${LF}"
      failure_examples_append "$@"
      ;;
  esac
}

references_end() {
  notable_examples_is_empty && failure_examples_is_empty && return 0
  notable_examples_flush
  failure_examples_flush
  putsn
}
