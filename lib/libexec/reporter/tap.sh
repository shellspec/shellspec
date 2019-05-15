#shellcheck shell=sh disable=SC2004

: "${example_count:-} ${aborted:-}"
: "${field_type:-} ${field_tag:-} ${field_description:-} ${field_message:-}"

tap_no=0

tap_begin() {
  putsn "1..$example_count"
}

tap_format() {
  _no=$tap_no

  case $field_type in (result)
    _no=$(($_no + 1))
    case $field_tag in
      succeeded) putsn "ok"     "$_no - $(field_description)" ;;
      warned   ) putsn "ok"     "$_no - $(field_description)" ;;
      failed   ) putsn "not ok" "$_no - $(field_description)" ;;
      skipped  ) putsn "ok"     "$_no - $(field_description) # skip" ;;
      todo     ) putsn "ok"     "$_no - $(field_description) # pending" ;;
      fixed    ) putsn "not ok" "$_no - $(field_description) # fixed" ;;
    esac
  esac

  tap_no=$_no
}

tap_end() {
  [ "$aborted" ] || return 0
  putsn "not ok $(($example_count + 1)) - aborted by unexpected error"
}
