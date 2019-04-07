#shellcheck shell=sh disable=SC2004

: "${field_tag:-}" "${field_description:-}" "${field_message:-}"

tap_formatter() {
  # shellcheck disable=SC2034
  SHELLSPEC_EXAMPLES_LOG=
  # shellcheck disable=SC2086
  _examples=$($SHELLSPEC_SHELL "$SHELLSPEC_LIBEXEC/shellspec-examples.sh" "$@")

  formatter_results_begin() {
    _example_no=0
    putsn "1..${_examples}"
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

  formatter_methods() { :; }
  formatter_conclusion_format() { :; }
  formatter_conclusion() { :; }
  formatter_references_format() { :; }
  formatter_references_end() { :; }
  formatter_finished() { :; }
  formatter_summary() { :; }
  formatter_fatal_error() { :; }
}
