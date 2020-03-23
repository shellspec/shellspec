#shellcheck shell=sh

: "${warned_count:-} ${skipped_count:-} ${suppressed_skipped_count:-}"
: "${todo_count:-} ${suppressed_todo_count:-}"
: "${fixed_count:-} ${suppressed_fixed_count:-}"
: "${interrupt:-} ${aborted:-} ${no_examples:-} ${not_enough_examples:-}"

create_buffers summary

summary_end() {
  _summary='' _summary_error='' _color=''

  pluralize _summary "${example_count:-0} example"
  pluralize _summary ", " "${failed_count:-0} failure"
  pluralize _summary ", " "$warned_count warning"
  pluralize _summary ", " "$skipped_count skip"
  pluralize _summary " (muted " "$suppressed_skipped_count skip" ")"
  pluralize _summary ", " "$todo_count pending"
  pluralize _summary " (muted " "$suppressed_todo_count pending" ")"
  pluralize _summary ", " "$fixed_count fix"
  pluralize _summary " (muted " "$suppressed_fixed_count fix" ")"

  if [ "$interrupt" ]; then
    _summary_error="$_summary_error, aborted by an interrupt"
  elif [ "$aborted" ]; then
    _summary_error="$_summary_error, aborted by an unexpected error"
  fi
  if [ "$no_examples" ]; then
    _summary_error="$_summary_error, no examples found"
  fi
  pluralize _summary_error ", " "$not_enough_examples example" \
    " did not run (unexpected exit?)"

  [ "$warned_count" ] && _color=$YELLOW || _color=$GREEN
  [ "${failed_count}${fixed_count}${_summary_error}" ] && _color=$RED
  summary '+=' "${_color}${_summary}${_summary_error}${RESET}${LF}${LF}"
}

summary_output() {
  case $1 in (end)
    summary '>>>'
  esac
}
