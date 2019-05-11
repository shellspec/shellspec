#shellcheck shell=sh disable=SC2004,SC2034

: "${warned_count:-} ${skipped_count:-} ${suppressed_skipped_count:-}"
: "${todo_count:-} ${fixed_count:-} ${suppressed_skipped_count:-}"
: "${interrupt:-} ${aborted:-} ${no_examples:-} ${not_enough_examples:-}"

summary_end() {
  summary=''
  callback() {
    [ "${1%% *}" ] || return 0
    summary="${summary}${summary:+, }$1"
    [ "${1%% *}" -eq 1 ] && return 0
    case $summary in (*x) summary="${summary}e"; esac
    summary="${summary}s"
  }

  each callback "${example_count:-0} example" "${failed_count:-0} failure" \
                "$warned_count warning" "$skipped_count skip"
  if [ "$suppressed_skipped_count" ]; then
    summary="$summary (muted $suppressed_skipped_count skip"
    [ "$suppressed_skipped_count" -ne 1 ] && summary="${summary}s"
    summary="$summary)"
  fi
  each callback "$todo_count pending" "$fixed_count fix"

  summary_error=''
  if [ "$interrupt" ]; then
    summary_error="$summary_error, aborted by an interrupt"
  elif [ "$aborted" ]; then
    summary_error="$summary_error, aborted by an unexpected error"
  fi
  if [ "$no_examples" ]; then
    summary_error="$summary_error, no examples found"
  fi
  if [ "$not_enough_examples" ]; then
    summary_error="$summary_error, some examples did not run"
  fi

  [ "$warned_count" ] && color=$YELLOW || color=$GREEN
  [ "$failed_count$fixed_count$summary_error" ] && color=$RED
  putsn "${color}${summary}${summary_error}${RESET}${LF}"
}
