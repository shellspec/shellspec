#shellcheck shell=sh disable=SC2004

: "${field_type:-} ${profiler_count:-} ${example_count:-}"

profiler_each() {
  [ "$SHELLSPEC_PROFILER" ] || return 0
  [ "$field_type" = example ] || return 0
  eval "profiler_line$example_count=\$field_specfile:\$field_lineno_begin"
}

profiler_output() {
  [ "$SHELLSPEC_PROFILER" ] || return 0
  case $1 in (end)
    _i=0
    while [ $_i -lt "$profiler_count" ]; do
      eval "putsn \$profiler_time$_i \"\$profiler_line$_i\""
      _i=$(($_i + 1))
    done | sort -k 1 -n -r | {
      _i=0
      #shellcheck disable=SC2034
      while IFS=" " read -r _tick _duration _line; do
        [ "$_i" -ge "$SHELLSPEC_PROFILER_LIMIT" ] && break
        _i=$(($_i + 1))
        putsn "${BOLD}${BLACK}$_i $_duration $_line${RESET}"
      done
    }
    putsn
  esac
}
