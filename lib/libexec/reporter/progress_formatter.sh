#shellcheck shell=sh

: "${field_type:-} ${field_tag:-} ${field_color:-}"

require_formatters methods conclusion finished summary references

buffer progress

progress_each() {
  progress '='
  case $field_type in (result)
    case $field_tag in
      succeeded ) progress '+=' "${field_color}.${RESET}" ;;
      warned    ) progress '+=' "${field_color}W${RESET}" ;;
      skipped   ) progress '+=' "${field_color}s${RESET}" ;;
      failed    ) progress '+=' "${field_color}F${RESET}" ;;
      todo      ) progress '+=' "${field_color}P${RESET}" ;;
      fixed     ) progress '+=' "${field_color}p${RESET}" ;;
    esac
  esac
}

progress_end() {
  progress '+=' "${LF}${LF}"
}

progress_output() {
  case $1 in (each | end)
    progress '>>'
  esac
  output "$1" methods conclusion finished summary references
}
