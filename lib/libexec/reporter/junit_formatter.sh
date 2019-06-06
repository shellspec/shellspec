#shellcheck shell=sh disable=SC2004

: "${count_examples:-} ${aborted:-} ${time_real:-} ${specfile_count:-}"
: "${field_type:-} ${field_fail:-} ${field_tag:-} ${field_description:-}"
: "${field_lineno:-} ${field_specfile:-} ${field_message:-}"
: "${field_failure_message:-}"

junit_testsuite=0 junit_tests=0 junit_failures=0 junit_skipped=0
junit_tests_total=0 junit_failures_total=0
create_buffers junit

junit_output="results_junit.xml"

junit_begin() {
  junit '=' "<?xml version=\"1.0\" encoding=\"UTF-8\"?>${LF}"
  junit '+=' "<testsuites name=\"\">${LF}"
  junit '>>>' >> "$SHELLSPEC_TMPBASE/${junit_output}.work"
}

junit_each() {
  _testsuite=$junit_testsuite
  _tests=$junit_tests _failures=$junit_failures _skipped=$junit_skipped
  _tests_total=$junit_tests_total _failures_total=$junit_failures_total

  _description='' _specfile='' _message='' _failure_message='' _timestamp=''

  case $field_type in
    meta) junit '=' ;;
    begin)
      _timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S')
      htmlescape _specfile "$field_specfile"
      junit '=' "  <testsuite name=\"$_specfile\"" \
        "hostname=\"$SHELLSPEC_HOSTNAME\"" \
        "id=\"$(($specfile_count - 1))\"" \
        "timestamp=\"$_timestamp\">${LF}"
      _tests=0 _failures=0 _skipped=0
      ;;
    example)
      htmlescape _description "$(field_description)"
      htmlescape _specfile "$field_specfile"
      junit '=' "    <testcase classname=\"$_specfile\" name=\"$_description\">"
      ;;
    statement)
      if [ "$field_fail" ]; then
        htmlescape _message "$field_message"
        htmlescape _failure_message "$field_failure_message"
        junit '+=' "${LF}      "
        junit '+=' "<failure message=\"$_message\">"
        junit '+=' "$_failure_message${LF}"
        junit '+=' "# ${field_specfile}:${field_lineno}"
        junit '+=' "</failure>${LF}    "
      else
        case $field_tag in (skip | pending)
          htmlescape _message "$field_message"
          junit '+='  "${LF}      <skip message=\"$_message\" />${LF}    "
        esac
      fi
      ;;
    result)
      _tests=$(($_tests + 1))
      _tests_total=$(($_tests_total + 1))
      if [ "$field_fail" ]; then
        _failures=$(($_failures + 1))
        _failures_total=$(($_failures_total + 1))
      else
        case $field_tag in (todo | skipped)
          _skipped=$(($_skipped + 1))
        esac
      fi
      junit '+=' "</testcase>${LF}"
      ;;
    end)
      junit '=' "  </testsuite>${LF}"
      eval "junit_tests_${_testsuite}=\$_tests"
      eval "junit_failures_${_testsuite}=\$_failures"
      eval "junit_skipped_${_testsuite}=\$_skipped"
      _testsuite=$(($_testsuite + 1))
      ;;
    finished)
      junit '='
      ;;
  esac
  junit '>>>' >> "$SHELLSPEC_TMPBASE/${junit_output}.work"

  junit_testsuite=$_testsuite
  junit_tests=$_tests junit_failures=$_failures junit_skipped=$_skipped
  junit_tests_total=$_tests_total junit_failures_total=$_failures_total
}

junit_end() {
  junit '=' "</testsuites>${LF}"
  junit '>>>' >> "$SHELLSPEC_TMPBASE/${junit_output}.work"
}

junit_output() {
  _testsuite=0 _tests='' _failures='' _skipped=''
  case $1 in (end)
    while IFS= read -r _line; do
      case $_line in
        *\<testsuites\ *)
          putsn "${_line%%<testsuites\ *}<testsuites" \
            "tests=\"$junit_tests_total\"" \
            "failures=\"$junit_failures_total\"" \
            "time=\"$time_real\"" \
            "${_line#*<testsuites\ }"
          ;;
        *\<testsuite\ *)
          eval "_tests=\$junit_tests_${_testsuite}"
          eval "_failures=\$junit_failures_${_testsuite}"
          eval "_skipped=\$junit_skipped_${_testsuite}"
          putsn "${_line%%<testsuite\ *}<testsuite" \
            "tests=\"$_tests\"" \
            "failures=\"$_failures\"" \
            "skipped=\"$_skipped\"" \
            "${_line#*<testsuite\ }"
          _testsuite=$(($_testsuite + 1))
          ;;
        *) putsn "$_line"
      esac
    done < "$SHELLSPEC_TMPBASE/${junit_output}.work"
  esac
}
