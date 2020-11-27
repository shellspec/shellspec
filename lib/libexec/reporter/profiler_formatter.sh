#shellcheck shell=sh disable=SC2154

profiler_each() {
  case $field_type in (example)
    eval "profiler_line$example_count=\$field_specfile:\$field_lineno_range"
  esac
}

profiler_end() {
  [ -e "$SHELLSPEC_PROFILER_LOG" ] || return 0
  mkdir -p "$SHELLSPEC_REPORTDIR"
  sleep_wait [ ! -e "$SHELLSPEC_TMPBASE/profiler.done" ] ||:
  callback() { eval "putsn \"\$5\" \"\${profiler_line$3:-0}\""; }
  read -r profiler_tick_total < "${SHELLSPEC_PROFILER_LOG}.total"
  # shellcheck disable=SC2031
  read_profiler callback "$profiler_tick_total" "$time_real" \
    < "$SHELLSPEC_PROFILER_LOG" \
    > "$SHELLSPEC_PROFILER_REPORT"
}

profiler_output() {
  [ "$SHELLSPEC_PROFILER" ] || return 0
  [ "$SHELLSPEC_PROFILER_LIMIT" -eq 0 ] && return 0
  case $1 in (end)
    _i=0 _slowest=$SHELLSPEC_PROFILER_LIMIT
    [ "$profiler_count" -le "$_slowest" ] && _slowest=$profiler_count
    puts "${BOLD}${GRAY}"
    putsn "# Top $_slowest slowest examples of the $profiler_count examples"

    if [ "$example_count" -gt 0 ] && [ "$profiler_count" -eq 0 ]; then
      putsn "# (Warning, An error has occurred in the profiler)"
    elif [ "$example_count" -ne "$profiler_count" ]; then
      putsn "# (Warning, A drop or an error has occurred in the profiler)"
    fi
    puts "${RESET}"

    while [ $_i -lt "$profiler_count" ]; do
      eval "putsn \$profiler_tick$_i \$profiler_time$_i \"\${profiler_line$_i:-}\""
      inc _i
    done | profiler_reverse_sort | (
      _i=0
      #shellcheck disable=SC2034
      while IFS=" " read -r _tick _duration _line; do
        [ "$_i" -ge "$SHELLSPEC_PROFILER_LIMIT" ] && break
        inc _i
        padding _prefix ' ' $((${#SHELLSPEC_PROFILER_LIMIT} - ${#_i}))
        putsn "${BOLD}${GRAY}#  ${_prefix}${_i} $_duration ${_line}${RESET}"
      done
    )
  esac
}

profiler_reverse_sort() {
  # Retry if sort is Windows version
  ( export LC_ALL=C; sort -k 1 -n -r 2>/dev/null || command -p sort -k 1 -n -r )
}
