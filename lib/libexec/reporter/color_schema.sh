#shellcheck shell=sh

: "${field_type:-} ${field_tag:-} ${field_pending:-} ${field_color:-}"

color_constants() {
  if [ "$1" ]; then
    callback() { eval "$1"; }
  else
    callback() { eval "${1%%=*}=''"; }
  fi

  set -- RESET="${ESC}[0m" \
    BOLD="${ESC}[1m" UNDERLINE="${ESC}[4m" REVERSE="${ESC}[7m" \
    BLACK="${ESC}[30m"   BG_BLACK="${ESC}[40m" \
    RED="${ESC}[31m"     BG_RED="${ESC}[41m" \
    GREEN="${ESC}[32m"   BG_GREEN="${ESC}[42m" \
    YELLOW="${ESC}[33m"  BG_YELLOW="${ESC}[43m" \
    BLUE="${ESC}[34m"    BG_BLUE="${ESC}[44m" \
    MAGENTA="${ESC}[35m" BG_MAGENTA="${ESC}[45m" \
    CYAN="${ESC}[36m"    BG_CYAN="${ESC}[46m" \
    WHITE="${ESC}[37m"   BG_WHITE="${ESC}[47m"
  each callback "$@"
}

color_schema() {
  field_color=''
  case $field_type in
    meta | finished) field_color=${BOLD}${WHITE} ;;
    begin | end) field_color=${REVERSE}${WHITE} ;;
    example) field_color=${UNDERLINE}${WHITE} ;;
    statement)
      case $field_tag in
        skip         ) field_color=${MAGENTA} ;;
        evaluation   ) field_color=${BOLD}${CYAN} ;;
        good         ) field_color=${GREEN} ;;
        warn         ) field_color=${YELLOW} ;;
        pending      ) field_color=${MAGENTA} ;;
        bad          ) field_color=${RED} ;;
        *            ) field_color=${WHITE} ;;
      esac
      ;;
    result)
      case $field_tag in
        succeeded    ) field_color=${BOLD}${GREEN} ;;
        failed       ) field_color=${BOLD}${RED} ;;
        warned       ) field_color=${BOLD}${YELLOW} ;;
        todo         ) field_color=${BOLD}${YELLOW} ;;
        fixed        ) field_color=${BOLD}${YELLOW} ;;
        skipped      ) field_color=${BOLD}${MAGENTA} ;;
      esac
  esac
}
