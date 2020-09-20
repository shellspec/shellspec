#shellcheck shell=sh disable=SC2154

require_formatters methods conclusion finished summary references profiler
[ "$SHELLSPEC_KCOV" ] && require_formatters kcov

create_buffers progress

progress_each() {
  case $field_type in (result)
    _mark=''
    case $field_tag in
      succeeded) _mark="." ;;
      warned   ) _mark="W" ;;
      skipped  ) [ "$field_temporary" ] && _mark="S" || _mark="s" ;;
      failed   ) _mark="F" ;;
      todo     ) [ "$field_temporary" ] && _mark="P" || _mark="p" ;;
      fixed    ) [ "$field_temporary" ] && _mark="=" || _mark="-" ;;
    esac
    progress '=' "${field_color}${_mark}${RESET}"
  esac
}

progress_end() {
  progress '=' "${LF}${LF}"
}

progress_output() {
  progress '>>>'
  output "$1" methods conclusion finished summary references
  if [ "$SHELLSPEC_KCOV" ]; then output "$1" kcov; fi
  output "$1" profiler
}
