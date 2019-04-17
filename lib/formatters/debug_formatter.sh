#shellcheck shell=sh

: "${field_type:-}" "${field_color:-}"

debug_formatter() {
  formatter_results_format() {
    case $field_type in
      begin    ) _mark="+" ;;
      end      ) _mark="-" ;;
      statement) _mark="*" ;;
      result   ) _mark="=" ;;
      *        ) _mark="?" ;;
    esac

    puts "${BOLD}${WHITE}${_mark} ${BOLD}${BLACK}<RS>"
    while [ $# -gt 0 ]; do
      eval "_value=\$field_$1"
      puts "${field_color}$1:${_value:-}"
      shift
      [ $# -eq 0 ] || puts "${BOLD}${BLACK}<US>"
    done
    putsn "${RESET}"
  }

  formatter_conclusion_format() { :; }
  formatter_conclusion_end() { :; }
  formatter_references_format() { :; }
  formatter_references_end() { :; }
  formatter_finished() { :; }
  formatter_summary() { :; }
}
