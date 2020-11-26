#shellcheck shell=sh disable=SC2154

require_formatters profiler

junit_testsuite=0 junit_tests=0 junit_failures=0 junit_skipped=0 \
junit_tests_total=0 junit_failures_total=0 junit_system_error='' \
junit_errors=0 junit_errors_total=0 junit_output="results_junit.xml"

create_buffers junit

junit_begin() {
  _attrs=''
  xmlattrs _attrs "name=$SHELLSPEC_PROJECT_NAME"
  junit '=' '<?xml version="1.0" encoding="UTF-8"?>'
  junit '+=' "${LF}<testsuites $_attrs>${LF}"
  junit '>>>' >> "$SHELLSPEC_TMPBASE/${junit_output}.work"
}

junit_each() {
  _text='' _attrs='' _testsuite=$junit_testsuite \
  _tests=$junit_tests _failures=$junit_failures _skipped=$junit_skipped \
  _tests_total=$junit_tests_total _failures_total=$junit_failures_total \
  _errors=$junit_errors _errors_total=$junit_errors_total \
  _system_error=$junit_system_error

  case $field_type in
    meta) junit '=' ;;
    begin)
      xmlattrs _attrs "name=$field_specfile" "hostname=$SHELLSPEC_HOSTNAME" \
        "timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S')"
      junit '=' "  <testsuite $_attrs>${LF}"
      _tests=0 _errors=0 _failures=0 _skipped=0
      ;;
    example)
      xmlattrs _attrs "classname=$field_specfile" "name=$(field_description)"
      junit '=' "    <testcase $_attrs>"
      ;;
    statement)
      if [ "$field_fail" ]; then
        xmlattrs _attrs "message=$field_message"
        _text="$field_failure_message${LF}# $field_specfile:$field_lineno"
        xmlcdata _text "$_text"
        junit '=' "${LF}      <failure $_attrs>$_text</failure>"
      else
        case $field_tag in (skip | pending)
          xmlattrs _attrs "message=$field_message"
          junit '='  "${LF}      <skip $_attrs />"
        esac
      fi
      ;;
    result)
      inc _tests _tests_total
      if [ "$field_fail" ]; then
        inc _failures _failures_total
      elif [ "$field_tag" = "todo" ] || [ "$field_tag" = "skipped" ]; then
        inc _skipped
      fi
      _stdout='' _stderr=''
      [ -r "$field_stdout" ] && readfile _stdout "$field_stdout"
      [ -r "$field_stderr" ] && readfile _stderr "$field_stderr"
      xmlcdata _stdout "$_stdout"
      xmlcdata _stderr "$_stderr"
      junit '=' "${LF}      <system-out>$_stdout</system-out>"
      junit '+=' "${LF}      <system-err>$_stderr</system-err>"
      junit '+=' "${LF}    </testcase>${LF}"
      ;;
    end)
      junit '='
      if [ "$_system_error" ]; then
        xmlcdata _system_error "$_system_error"
        junit '+=' "    <system-err>$_system_error</system-err>${LF}"
        _system_error=''
      fi
      junit '+=' "  </testsuite>${LF}"
      eval "junit_tests_${_testsuite}=\$_tests"
      eval "junit_errors_${_testsuite}=\$_errors"
      eval "junit_failures_${_testsuite}=\$_failures"
      eval "junit_skipped_${_testsuite}=\$_skipped"
      inc _testsuite
      ;;
    error)
      inc _errors _errors_total
      _message="${field_note}${field_note:+: }${field_message}"
      _failure=$field_failure_message _address="$field_specfile:$field_lineno"
      wrap _failure "${_failure%${LF}}${LF}" "  "
      _system_error="${_system_error}${_message}${LF}${_failure}"
      _system_error="${_system_error}# ${_address}${LF}${LF}"
      ;;
    finished) junit '=' ;;
  esac
  junit '>>>' >> "$SHELLSPEC_TMPBASE/${junit_output}.work"

  junit_testsuite=$_testsuite junit_system_error=$_system_error \
  junit_tests=$_tests junit_failures=$_failures junit_skipped=$_skipped \
  junit_tests_total=$_tests_total junit_failures_total=$_failures_total \
  junit_errors=$_errors junit_errors_total=$_errors_total
}

junit_end() {
  junit '=' "</testsuites>${LF}"
  junit '>>>' >> "$SHELLSPEC_TMPBASE/${junit_output}.work"
}

junit_output() {
  _id=0 _cid=0 _before='' _after='' _attrs='' _time=''
  case $1 in (end)
    while IFS= read -r _line; do
      case $_line in
        *\<testsuites\ *)
          _before=${_line%%<testsuites\ *} _after=${_line#*<testsuites\ }
          xmlattrs _attrs "tests=$junit_tests_total" "time=$time_real" \
            "errors=$junit_errors_total" "failures=$junit_failures_total"
          putsn "$_before<testsuites $_attrs $_after"
          ;;
        *\<testsuite\ *)
          _before=${_line%%<testsuite\ *} _after=${_line#*<testsuite\ }
          eval "xmlattrs _attrs id=$_id tests=\$junit_tests_${_id} \
            errors=\$junit_errors_${_id} failures=\$junit_failures_${_id} \
            skipped=\$junit_skipped_${_id}"
          putsn "$_before<testsuite $_attrs $_after"
          inc _id
          ;;
        *\<testcase\ *)
          _before=${_line%%<testcase\ *} _after=${_line#*<testcase\ }
          _time=0
          [ "$SHELLSPEC_PROFILER" ] && eval "_time=\$profiler_time$_cid"
          xmlattrs _attrs "time=$_time"
          putsn "$_before<testcase $_attrs $_after"
          inc _cid
          ;;
        *) putsn "$_line"
      esac
    done < "$SHELLSPEC_TMPBASE/${junit_output}.work"
  esac
}
