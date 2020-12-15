#shellcheck shell=sh disable=SC2154

create_buffers kcov

kcov_end() {
  _line='' _key='' _value='' _color='' \
  _percent_covered='' _covered_lines='' _total_lines='' \
  _percent_low='' _percent_high='' \
  _coverage="$SHELLSPEC_COVERAGEDIR/$SHELLSPEC_KCOV_FILENAME/coverage.json"
  #shellcheck disable=SC2034
   _command='' _date=''

  [ -f "$_coverage" ] || return 0

  while IFS= read -r _line; do
    trim _key "${_line%%:*}"
    trim _value "${_line#*:}"
    _key=${_key#\"} _key=${_key%\"} _value=${_value%,}
    _value=${_value#\"} _value=${_value%\"}
    case $_key in
      percent_covered | covered_lines | total_lines) ;;
      percent_low | percent_high | command | date) ;;
      *) continue
    esac
    eval "_$_key=\$_value"
  done < "$_coverage"

  _color=$RED
  [ "${_percent_covered%.*}" -ge "${_percent_low%.*}" ] && _color=$YELLOW
  [ "${_percent_covered%.*}" -ge "${_percent_high%.*}" ] && _color=$GREEN
  # shellcheck disable=SC2034
  [ "$_color" = "$RED" ] && coverage_failed=1

  kcov '=' "$_color"
  kcov '+=' "Code covered: ${_percent_covered}%, "
  kcov '+=' "Executed lines: ${_covered_lines}, "
  kcov '+=' "Instrumented lines: ${_total_lines}"
  kcov '+=' "${RESET}${LF}${LF}"
}

kcov_output() {
  case $1 in (end)
    [ "$aborted" ] && return 0
    kcov '>>>'
  esac
}
