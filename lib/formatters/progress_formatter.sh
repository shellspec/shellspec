#shellcheck shell=sh

: "${field_tag:-} ${field_color:-} ${field_message:-}"

progress_formatter() {
  formatter_begin() {
    methods
    conclusion_begin
    references_begin
  }

  formatter_format() {
    conclusion_format "$@"
    references_format "$@"

    case $field_tag in
      succeeded ) puts "${field_color}.${RESET}" ;;
      warned    ) puts "${field_color}W${RESET}" ;;
      skipped   ) puts "${field_color}s${RESET}" ;;
      failed    ) puts "${field_color}F${RESET}" ;;
      todo      ) puts "${field_color}P${RESET}" ;;
      fixed     ) puts "${field_color}p${RESET}" ;;
      log       ) puts "${field_color}${field_message}${RESET}${LF}" ;;
    esac
  }

  formatter_end() {
    putsn
    conclusion_end
    finished
    summary
    references_end
  }
}
