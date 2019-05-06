#shellcheck shell=sh disable=SC2004

: "${example_count:-} ${aborted:-}"
: "${field_type:-} ${field_tag:-} ${field_description:-} ${field_message:-}"

tap_formatter() {
  count "$@"

  formatter_begin() {
    _example_no=0
    putsn "1..$example_count"
  }

  formatter_format() {
    [ "$field_type" = "result" ] && _example_no=$(($_example_no + 1))

    _description=${field_description:-}
    replace _description "$VT" " "
    case $field_tag in
      succeeded) putsn "ok $_example_no - $_description" ;;
      warned   ) putsn "ok $_example_no - $_description" ;;
      failed   ) putsn "not ok $_example_no - $_description" ;;
      skipped  ) putsn "ok $_example_no - $_description # skip" ;;
      todo     ) putsn "ok $_example_no - $_description # pending" ;;
      fixed    ) putsn "not ok $_example_no - $_description # fixed" ;;
    esac
  }

  formatter_end() {
    [ "$aborted" ] || return 0
    putsn "not ok $(($example_count + 1)) - aborted by unexpected error"
  }
}
