#shellcheck shell=sh disable=SC2004,SC2034

: "${warned_count:-} ${skipped_count:-} ${suppressed_skipped_count:-}"
: "${todo_count:-} ${fixed_count:-} ${suppressed_skipped_count:-}"
: "${interrupt:-} ${aborted:-} ${no_examples:-}"

summary_end() {
  summary=''
  callback() {
    [ "${1%% *}" ] || return 0
    summary="${summary}${summary:+, }$1"
    [ "${1%% *}" -eq 1 ] && return 0
    case $summary in (*x) summary="${summary}e"; esac
    summary="${summary}s"
  }

  each callback "${total_count:-0} example" "${failed_count:-0} failure" \
                "$warned_count warning" "$skipped_count skip"
  if [ "$suppressed_skipped_count" ]; then
    summary="$summary (muted $suppressed_skipped_count skip"
    [ "$suppressed_skipped_count" -ne 1 ] && summary="${summary}s"
    summary="$summary)"
  fi
  each callback "$todo_count pending" "$fixed_count fix"
  if [ "$interrupt" ]; then
    summary="$summary, aborted by an interrupt"
  elif [ "$aborted" ]; then
    summary="$summary, aborted by an unexpected error"
  fi
  [ "$no_examples" ] && summary="$summary, no examples found"

  [ "$warned_count" ] && color=$YELLOW || color=$GREEN
  [ "$failed_count$fixed_count$aborted$interrupt$no_examples" ] && color=$RED
  putsn "${color}${summary}${RESET}${LF}"
}
