#shellcheck shell=sh

: "${field_example_no:-}"  "${field_tag:-}" "${field_description:-}"

tap_formatter() {
  formatter_results_format() {
    case ${field_type:-} in
      statement) [ "${field_tag:-}" = "log" ] || return 0 ;;
      result) ;;
      *) return 0 ;;
    esac

    : "${_buffering=1}"

    if [ "$_buffering" ] && wait_for_log_exists "$SHELLSPEC_TRANS_LOG"; then
      _trans_examples=0
      read_log "_trans" "$SHELLSPEC_TRANS_LOG"
      putsn "1..${_trans_examples}"
      puts "${_buffer:-}"
      _buffering='' _buffer=''
    fi

    _line=''
    case $field_tag in
      succeeded | warned)
        _line="ok $field_example_no - $field_description" ;;
      failed)
        _line="not ok $field_example_no - $field_description" ;;
      skipped)
        _line="ok $field_example_no - $field_description # skip" ;;
      todo)
        _line="ok $field_example_no - $field_description # pending" ;;
      fixed)
        _line="not ok $field_example_no - $field_description # fixed" ;;
      log)
        _line="# $field_message" ;;
    esac

    if [ "$_buffering" ]; then
      _buffer="${_buffer:-}${_line}${LF}"
    else
      putsn "$_line"
    fi
  }

  formatter_results_end() {
    puts "${_buffer:-}"
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
