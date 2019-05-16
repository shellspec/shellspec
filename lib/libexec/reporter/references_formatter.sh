#shellcheck shell=sh disable=SC2004,SC2034

: "${example_index:-} ${example_count_per_file:-}"
: "${field_type:-} ${field_specfile:-} ${field_range:-} ${field_focused:-}"
: "${field_color:-} ${field_error:-} ${field_note:-} ${field_example_count:-}"

buffer references_notable
buffer references_failure

references_formatter() {
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
          references_failure set_if_empty "Failure examples:${LF}"
          references_failure append "$@"
        else
          references_notable set_if_empty "Notable examples:" \
            "(listed here are expected and do not affect your suite's status)$LF"
          references_notable append "$@"
        fi
        ;;
      end)
        [ "$example_count_per_file" -eq "$field_example_count" ] && return 0

        set -- "${RED}shellspec $field_specfile${RESET}" \
          "$CYAN# expected $field_example_count examples," \
          "but only ran $example_count_per_file examples${RESET}"

        references_failure set_if_empty "Failure examples:${LF}"
        references_failure append "$@"
        ;;
    esac
  }

  references_output() {
    case $1 in
      end)
        if ! references_notable is_empty; then
          references_notable output
          putsn
        fi
        if ! references_failure is_empty; then
          references_failure output
          putsn
        fi
    esac
  }
}
