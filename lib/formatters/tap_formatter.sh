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

    case $field_tag in
      succeeded) putsn "ok $_example_no - $field_description" ;;
      warned   ) putsn "ok $_example_no - $field_description" ;;
      failed   ) putsn "not ok $_example_no - $field_description" ;;
      skipped  ) putsn "ok $_example_no - $field_description # skip" ;;
      todo     ) putsn "ok $_example_no - $field_description # pending" ;;
      fixed    ) putsn "not ok $_example_no - $field_description # fixed" ;;
      log      ) putsn "# $field_message" ;;
    esac
  }

  formatter_end() {
    [ "$aborted" ] || return 0
    putsn "not ok $(($example_count + 1)) - aborted by unexpected error"
  }
}
