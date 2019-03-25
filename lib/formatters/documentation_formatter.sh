#shellcheck shell=sh

: "${example_index:-}" "${field_tag:-}" "${field_type:-}" "${field_note:-}"
: "${field_desc:-}" "${field_color:-}"

documentation_formatter() {
  formatter_results_format() {
    : "${_indent:=}"

    if [ "$field_tag" = "example_group" ]; then
      case $field_type in
        begin)
          [ "$_indent" ] || putsn
          putsn "${_indent}${field_color}${field_desc}${RESET}"
          _indent="$_indent  " ;;
        end) _indent="${_indent%  }" ;;
      esac
    fi

    case $field_type in
      statement)
        [ "$field_tag" = "log" ] || return 0
        putsn "${_indent}${field_color}${field_message}${RESET}"
        ;;
      result)
        set -- "${_indent}${field_color}${field_desc}"
        [ "$example_index" ] && set -- "$@" "(${field_note:-} - $example_index)"
        putsn "$*${RESET}"
        ;;
    esac
  }
}
