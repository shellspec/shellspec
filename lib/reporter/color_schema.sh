#shellcheck shell=sh

: "${field_tag:-}" "${field_pending:-}" "${field_color:-}"
: "${COLOR_DEBUG:-}"

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
  while [ $# -gt 0 ]; do
    callback "$1"
    shift
  done
}

color_schema() {
  case $field_tag in
    example_group) field_color=$WHITE ;;
    example) field_color=$BLUE ;;
    succeeded) field_color=$BOLD$GREEN
      [ -z "$field_pending" ] || field_color=$BOLD$YELLOW ;;
    warned |fixed | todo) field_color=$BOLD$YELLOW ;;
    failed   ) field_color=$BOLD$RED
      [ -z "$field_pending" ] || field_color=$BOLD$RED ;;
    skip ) field_color=$MAGENTA ;;
    skipped) field_color=$BOLD$MAGENTA ;;
    evaluation) field_color=${BOLD}${CYAN} ;;
    good) field_color=$GREEN
      [ -z "$field_pending" ] || field_color=$YELLOW ;;
    warn) field_color=$YELLOW ;;
    pending) field_color=$MAGENTA ;;
    bad      ) field_color=$RED
      [ -z "$field_pending" ] || field_color=$YELLOW ;;
    log) field_color=$BOLD${UNDERLINE}$WHITE ;;
    *        ) field_color=$WHITE ;;
  esac

  COLOR_DEBUG=${WHITE}${BOLD}
}
