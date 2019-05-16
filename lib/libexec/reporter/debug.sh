#shellcheck shell=sh

: "${field_type:-} ${field_color:-}"

buffer debug

debug_format() {
  _mark='' _value=''
  debug_clear

  case $field_type in
    meta     ) _mark='!' ;;
    begin    ) _mark='#' ;;
    example  ) _mark='%' ;;
    statement) _mark='*' ;;
    result   ) _mark='=' ;;
    end      ) _mark='$' ;;
    finished ) _mark='&' ;;
    *        ) _mark='?' ;;
  esac

  debug_add "${BOLD}${WHITE}${_mark} ${field_color}${BOLD}${BLACK}<RS>${field_color}"
  while [ $# -gt 0 ]; do
    eval "_value=\$field_$1"
    replace _value "$VT" "${BOLD}${BLACK}<VT>${field_color}"
    debug_add "${field_color}$1:${_value}"
    shift
    [ $# -eq 0 ] || debug_add "${BOLD}${BLACK}<US>${field_color}"
  done
  debug_append "${RESET}"
}

debug_output() {
  case $1 in
    format) debug_puts ;;
  esac
}
