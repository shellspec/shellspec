#shellcheck shell=sh disable=SC2004

: "${profiler_count:-} ${example_count:-}"

profiler_output() {
  [ "$SHELLSPEC_PROFILER" ] || return 0
  [ "$SHELLSPEC_PROFILER_LIMIT" -eq 0 ] && return 0
  case $1 in (end)
    _i=0 _slowest=$SHELLSPEC_PROFILER_LIMIT
    [ "$profiler_count" -le "$_slowest" ] && _slowest=$profiler_count
    puts "${BOLD}${BLACK}"
    putsn "Top $_slowest slowest examples of the $profiler_count examples"

    if [ "$example_count" -gt 0 ] && [ "$profiler_count" -eq 0 ]; then
      putsn "(Warning, An error has occurred in the profiler)"
    elif [ "$example_count" -ne "$profiler_count" ]; then
      putsn "(Warning, A drop or an error has occurred in the profiler)"
    fi
    puts "${RESET}"

    while [ $_i -lt "$profiler_count" ]; do
      eval "putsn \$profiler_tick$_i \$profiler_time$_i \"\$profiler_line$_i\""
      _i=$(($_i + 1))
    done | sort -k 1 -n -r | (
      _i=0
      #shellcheck disable=SC2034
      while IFS=" " read -r _tick _duration _line; do
        [ "$_i" -ge "$SHELLSPEC_PROFILER_LIMIT" ] && break
        _i=$(($_i + 1))
        while [ "${#_i}" -lt "${#SHELLSPEC_PROFILER_LIMIT}" ]; do
          _i=" $_i"
        done
        putsn "${BOLD}${BLACK} $_i $_duration $_line${RESET}"
      done
    )
    putsn
  esac
}
