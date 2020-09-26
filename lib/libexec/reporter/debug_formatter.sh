#shellcheck shell=sh disable=SC2154

create_buffers debug

debug_each() {
  _mark='' _value=''

  case $field_type in
    meta     ) _mark='!' ;;
    begin    ) _mark='#' ;;
    example  ) _mark='%' ;;
    statement) _mark='*' ;;
    result   ) _mark='=' ;;
    end      ) _mark='$' ;;
    finished ) _mark='&' ;;
    error    ) _mark='-' ;;
    *        ) _mark='?' ;;
  esac

  debug '=' "${BOLD}${GRAY}${_mark}"
  debug '+=' "${field_color}${BOLD}${GRAY}<RS>${field_color}"
  while [ $# -gt 0 ]; do
    eval "_value=\$field_$1"
    replace_all _value "$VT" "${GRAY}<VT>${field_color}"
    debug '+=' "${field_color}$1:${_value}"
    shift
    [ $# -eq 0 ] || debug '+=' "${BOLD}${GRAY}<US>${field_color}"
  done
  debug '+=' "${RESET}${LF}"
}

debug_output() {
  debug '>>>'
}
