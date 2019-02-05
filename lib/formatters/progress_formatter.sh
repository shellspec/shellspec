#shellcheck shell=sh

: "${field_tag:-}" "${field_color:-}"

progress_formatter() {
  formatter_results_format() {
    case $field_tag in
      succeeded ) puts "${field_color}.${RESET}" ;;
      warned    ) puts "${field_color}W${RESET}" ;;
      skipped   ) puts "${field_color}s${RESET}" ;;
      failed    ) puts "${field_color}F${RESET}" ;;
      todo      ) puts "${field_color}P${RESET}" ;;
      fixed     ) puts "${field_color}p${RESET}" ;;
    esac
  }

  formatter_results_end() {
    putsn
  }
}
