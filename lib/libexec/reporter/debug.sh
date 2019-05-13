#shellcheck shell=sh

: "${field_type:-} ${field_color:-}"

debug_format() {
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

  puts "${BOLD}${WHITE}${_mark} ${field_color}${BOLD}${BLACK}<RS>${field_color}"
  while [ $# -gt 0 ]; do
    eval "_value=\$field_$1"
    replace _value "$VT" "${BOLD}${BLACK}<VT>${field_color}"
    puts "${field_color}$1:${_value:-}"
    shift
    [ $# -eq 0 ] || puts "${BOLD}${BLACK}<US>${field_color}"
  done
  putsn "${RESET}"
}
