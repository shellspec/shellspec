#shellcheck shell=sh disable=SC2154

create_buffers summary

summary_end() {
  _summary='' _error='' _warning='' _color=''

  pluralize _summary "${example_count:-0} example"
  pluralize _summary ", " "${failed_count:-0} failure"
  pluralize _summary ", " "$error_count error"
  pluralize _summary ", " "$warned_count warning"
  pluralize _summary ", " "$skipped_count skip"
  pluralize _summary " (muted " "$suppressed_skipped_count skip" ")"
  pluralize _summary ", " "$todo_count pending"
  pluralize _summary " (muted " "$suppressed_todo_count pending" ")"
  pluralize _summary ", " "$fixed_count fix"
  pluralize _summary " (muted " "$suppressed_fixed_count fix" ")"

  if [ "$interrupt" ]; then
    _error="$_error, aborted by an interrupt"
  elif [ "$aborted" ]; then
    _error="$_error, aborted by an unexpected error"
  fi
  if [ "$no_examples" ]; then
    _error="$_error, no examples found"
  fi
  pluralize _error ", " "$not_enough_examples example" \
    " did not run (unexpected exit?)"

  if [ "$SHELLSPEC_DRYRUN" ]; then
    _warning="$_warning [dry-run mode]"
  elif [ "$SHELLSPEC_XTRACE_ONLY" ]; then
    _warning="$_warning [trace-only mode]"
  fi

  [ "${warned_count}${_warning}" ] && _color=$YELLOW || _color=$GREEN
  [ "${failed_count}${error_count}${fixed_count}${_error}" ] && _color=$RED
  summary '+=' "${_color}${_summary}${_error}${_warning}${RESET}${LF}${LF}"
}

summary_output() {
  case $1 in (end)
    summary '>>>'
  esac
}
