#shellcheck shell=sh disable=SC2004,SC2034

: "${example_index:-}"
: "${field_type:-} ${field_specfile:-} ${field_range:-}"
: "${field_color:-} ${field_focused:-} ${field_error:-} ${field_note:-}"

buffer notable_examples failure_examples

references_format() {
  [ "$field_type" = "result" ] || return 0
  [ -z "$example_index" ] && [ "$field_focused" != "focus" ] && return 0

  set -- "${field_color}shellspec" \
    "$field_specfile:${field_range%-*}${RESET}" \
    "${CYAN}# ${example_index:--}) $(field_description) ${field_note}${RESET}"

  # shellcheck disable=SC2145
  [ "$field_focused" = "focus" ] && set -- "${UNDERLINE}$@"

  if [ "$field_error" ]; then
    failure_examples_set_if_empty "Failure examples:${LF}"
    failure_examples_append "$@"
  else
    notable_examples_set_if_empty "Notable examples: " \
      "(listed here are expected and do not affect your suite's status)${LF}"
    notable_examples_append "$@"
  fi
}

references_end() {
  notable_examples_flush
  failure_examples_flush
}
