#shellcheck shell=sh

: "${field_type:-} ${field_tag:-} ${field_color:-}"

progress_format() {
  case $field_type in (result)
    case $field_tag in
      succeeded ) puts "${field_color}.${RESET}" ;;
      warned    ) puts "${field_color}W${RESET}" ;;
      skipped   ) puts "${field_color}s${RESET}" ;;
      failed    ) puts "${field_color}F${RESET}" ;;
      todo      ) puts "${field_color}P${RESET}" ;;
      fixed     ) puts "${field_color}p${RESET}" ;;
    esac
  esac
}

progress_end() {
  putsn
}
