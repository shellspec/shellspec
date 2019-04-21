#shellcheck shell=sh disable=SC2004

: "${field_tag:-}" "${field_description:-}" "${field_message:-}" "${aborted:-}"

tap_formatter() {
  # shellcheck disable=SC2086
  _count=$(count "$@")
  _count=${_count#* }

  formatter_results_begin() {
    _example_no=0
    putsn "1..${_count}"
  }

  formatter_results_format() {
    [ "${field_type:-}" = "result" ] && _example_no=$(($_example_no + 1))

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

  formatter_results_end() {
    if [ "$aborted" ]; then
      putsn "not ok $(($_count + 1)) - aborted by unexpected error"
    fi
  }

  formatter_methods() { :; }
  formatter_conclusion_format() { :; }
  formatter_conclusion() { :; }
  formatter_references_format() { :; }
  formatter_references_end() { :; }
  formatter_finished() { :; }
  formatter_summary() { :; }
}
