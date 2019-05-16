#shellcheck shell=sh

: "${field_type:-} ${field_tag:-} ${field_color:-}"

buffer progress

progress_formatter() {
  formatter progress
  load_formatters methods conclusion finished summary references

  progress_format() {
    progress clear
    case $field_type in (result)
      case $field_tag in
        succeeded ) progress add "${field_color}.${RESET}" ;;
        warned    ) progress add "${field_color}W${RESET}" ;;
        skipped   ) progress add "${field_color}s${RESET}" ;;
        failed    ) progress add "${field_color}F${RESET}" ;;
        todo      ) progress add "${field_color}P${RESET}" ;;
        fixed     ) progress add "${field_color}p${RESET}" ;;
      esac
    esac
  }

  progress_end() {
    progress append
  }

  progress_output() {
    case $1 in
      format | end) progress output ;;
    esac
    output "$1" methods conclusion finished summary references
  }
}
