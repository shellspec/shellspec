#shellcheck shell=sh disable=SC2004

: "${example_count:-} ${aborted:-}"
: "${field_type:-} ${field_tag:-} ${field_description:-} ${field_message:-}"

tap_no=0
buffer tap

tap_formatter() {
  count "$@"
  formatter tap

  tap_begin() {
    tap append "1..$example_count"
  }

  tap_format() {
    _no=$tap_no
    tap clear

    case $field_type in (result)
      _no=$(($_no + 1))
      case $field_tag in
        succeeded) tap append "ok"     "$_no - $(field_description)" ;;
        warned   ) tap append "ok"     "$_no - $(field_description)" ;;
        failed   ) tap append "not ok" "$_no - $(field_description)" ;;
        skipped  ) tap append "ok"     "$_no - $(field_description) # skip" ;;
        todo     ) tap append "ok"     "$_no - $(field_description) # pending" ;;
        fixed    ) tap append "not ok" "$_no - $(field_description) # fixed" ;;
      esac
    esac

    tap_no=$_no
  }

  tap_end() {
    [ "$aborted" ] || return 0
    tap clear
    tap append "not ok $(($example_count + 1)) - aborted by unexpected error"
  }

  tap_output() {
    case $1 in
      begin | format | end ) tap output ;;
    esac
  }
}
