#shellcheck shell=sh

: "${field_type:-} ${field_tag:-} ${field_color:-}"

buffer progress

progress_format() {
  progress_clear
  case $field_type in (result)
    case $field_tag in
      succeeded ) progress_add "${field_color}.${RESET}" ;;
      warned    ) progress_add "${field_color}W${RESET}" ;;
      skipped   ) progress_add "${field_color}s${RESET}" ;;
      failed    ) progress_add "${field_color}F${RESET}" ;;
      todo      ) progress_add "${field_color}P${RESET}" ;;
      fixed     ) progress_add "${field_color}p${RESET}" ;;
    esac
  esac
}

progress_end() {
  progress_append
}

progress_output() {
  case $1 in
    format)
      methods_output format
      progress_puts
      ;;
    end)
      progress_puts
      conclusion_output end
      finished_output end
      summary_output end
      references_output end
      ;;
  esac
}
