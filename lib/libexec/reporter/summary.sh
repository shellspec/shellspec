#shellcheck shell=sh disable=SC2004,SC2034

: "${warned_count:-} ${skipped_count:-} ${suppressed_skipped_count:-}"
: "${todo_count:-} ${fixed_count:-} ${suppressed_skipped_count:-}"
: "${interrupt:-} ${aborted:-} ${no_examples:-} ${not_enough_examples:-}"

buffer summary

summary_end() {
  _summary='' _summary_error='' _color=''

  callback() {
    [ "${1%% *}" ] || return 0
    _summary="${_summary}${_summary:+, }$1"
    [ "${1%% *}" -eq 1 ] && return 0
    case $_summary in (*x) _summary="${_summary}e"; esac
    _summary="${_summary}s"
  }
  each callback "${example_count:-0} example" "${failed_count:-0} failure" \
                "$warned_count warning" "$skipped_count skip"
  if [ "$suppressed_skipped_count" ]; then
    _summary="$_summary (muted $suppressed_skipped_count skip"
    [ "$suppressed_skipped_count" -ne 1 ] && _summary="${_summary}s"
    _summary="$_summary)"
  fi
  each callback "$todo_count pending" "$fixed_count fix"

  if [ "$interrupt" ]; then
    _summary_error="$_summary_error, aborted by an interrupt"
  elif [ "$aborted" ]; then
    _summary_error="$_summary_error, aborted by an unexpected error"
  fi
  if [ "$no_examples" ]; then
    _summary_error="$_summary_error, no examples found"
  fi
  if [ "$not_enough_examples" ]; then
    _summary_error="$_summary_error, some examples did not run"
  fi

  [ "$warned_count" ] && _color=$YELLOW || _color=$GREEN
  [ "${failed_count}${fixed_count}${_summary_error}" ] && _color=$RED
  summary append "${_color}${_summary}${_summary_error}${RESET}${LF}"
}

summary_output() {
  case $1 in
    end) summary output ;;
  esac
}
