#shellcheck shell=sh disable=SC2004

: "${meta_shell:-}" "${meta_shell_type:-}" "${meta_shell_version:-}"
: "${example_index:-}" "${detail_index:-}"
: "${field_specfile:-}" "${field_type:-}" "${field_tag:-}" "${field_range:-}"
: "${field_lineno:-}" "${field_color:-}"

buffer conclusion notable_examples failure_examples fatal_errors

proxy formatter_methods methods
proxy formatter_conclusion_format conclusion_format
proxy formatter_conclusion_end conclusion_end
proxy formatter_finished finished_end
proxy formatter_summary summary_end
proxy formatter_references_format references_format
proxy formatter_references_end references_end
proxy formatter_fatal_error fatal_error_format

formatter_results_begin() { :; }
formatter_results_format() { :; }
formatter_results_end() { :; }

formatter_begin() {
  formatter_methods
  formatter_results_begin
}

formatter_format() {
  formatter_conclusion_format "$@"
  formatter_references_format "$@"
  formatter_results_format "$@"
}

formatter_end() {
  formatter_results_end
  formatter_conclusion_end
  formatter_finished
  formatter_summary
  formatter_references_end
}

methods() {
  putsn "Running: $meta_shell" \
    "[$meta_shell_type${meta_shell_version:+ }$meta_shell_version]"
}

conclusion_format() {
  [ "$field_type" = "statement" ] || return 0
  case $field_tag in (evaluation|log) return 0; esac
  [ "$example_index" ] || return 0

  conclusion_set_if_empty "${LF}Examples:${LF}"
  label="  $example_index) " indent=''
  padding indent ' ' ${#label}
  if [ "$detail_index" -eq 1 ]; then
    conclusion_append "${WHITE}${label}${field_description:-}${RESET}"
    if [ "${field_evaluation:-}" ]; then
      conclusion_append "${BOLD}${CYAN}${indent}${field_evaluation:-}${RESET}"
      conclusion_append
    fi
  fi

  label="${indent}${example_index}.${detail_index}) " indent=''
  padding indent ' ' ${#label}

  case $field_tag in
    bad) tag='Failure' ;;
    warn) tag='Warning' ;;
    *) tag='' ;;
  esac

  message="${tag}${tag:+: }${field_message:-}" note=${field_note:-}
  conclusion_append "${label}${field_color}${message} ${note}${RESET}"

  message=${LF}${field_failure_message:-} text=''
  while [ "$text" != "$message" ]; do
    text=${message%%${LF}*} message=${message#*${LF}}
    conclusion_append "  ${indent}${field_color}${text}${RESET}"
  done

  if [ "$note" = FIXED ]; then
    conclusion_append "${indent}${CYAN}#" \
      "Expected pending to fail. No error was raised.${RESET}"
  fi
  conclusion_append "${indent}${CYAN}#" \
    "${field_specfile}:${field_lineno}${RESET}${LF}"
}

conclusion_end() {
  conclusion_flush
}

finished_end() {
  if [ "${trans_user:-}" ] && [ "${trans_sys:-}" ]; then
    trans_time=$(printf '%d.%02d' \
      $((${trans_user%.*}+${trans_sys%.*} +
        (1${trans_user#*.}+1${trans_sys#*.}-200) / 100 )) \
      $(( (1${trans_user#*.}+1${trans_sys#*.}-200) % 100 ))
    )
  else
    trans_time="?"
  fi
  putsn "Finished in ${time_real:-?} seconds" \
    "(files took ${trans_time:-?} seconds to translate)"
}

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
                "${warned_count:-} warning" "${skipped_count:-} skip"
  if [ "${suppressed_skipped_count:-}" ]; then
    summary="${summary} (muted $suppressed_skipped_count skip"
    [ "$suppressed_skipped_count" -ne 1 ] && summary="${summary}s"
    summary="${summary})"
  fi
  each callback "${todo_count:-} pending"   "${fixed_count:-} fix" \
                "${fatal_error_count:-} fatal error"
  [ "${interrupt:-}" ] && summary="${summary}, aborted by an interrupt"

  [ "${warned_count:-}" ] && color=$YELLOW || color=$GREEN
  [ "${failed_count:-}${fatal_error_count:-}${interrupt}" ] && color=$RED
  putsn "${color}${summary}${RESET}${LF}"
}

references_format() {
  [ "$field_type" = "result" ] || return 0
  [ "${example_index}" ] || return 0

  set -- "${field_color}shellspec" \
    "${field_specfile}:${field_range%-*}${RESET}" \
    "${CYAN}# ${example_index})" "${field_description} ${field_note:-}${RESET}"

  if [ "${field_error:-}" ]; then
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
  fatal_errors_flush
}

fatal_error_format() {
  example_index=$((${example_index:-0} + 1))
  conclusion_append "${LF}${RED}Fatal error:" \
    "running specs aborted unexpectedly${LF}${RESET}"
  conclusion_append \
    "  ${BOLD}${WHITE}NOTE: The last executed statement was as follows${RESET}"
  conclusion_append "${LF}  $example_index) ${field_description:-}${LF}"
  if [ "${field_evaluation:-}" ]; then
    conclusion_append "     ${BOLD}${CYAN}${field_evaluation:-}${RESET}"
  fi

  if [ "${field_type:-}" = "statement" ]; then
    conclusion_append \
      "     ${field_color:-}${field_message:-} (${field_tag:-})${RESET}"
  else
    conclusion_append "     (${field_tag:-} ${field_type:-})"
  fi

  if [ "${field_lineno:-}" ]; then
    conclusion_append \
      "     ${CYAN}# ${field_specfile}:${field_lineno}${RESET}"
    set -- "${BOLD}${RED}shellspec" \
      "${field_specfile}:${field_lineno}${RESET}" \
      "${CYAN}# $example_index)" "${field_description}${RESET}"
  else
    conclusion_append \
      "     ${CYAN}# ${field_specfile:-}:${field_range:-}${RESET}"
    set -- "${BOLD}${RED}shellspec" \
      "${field_specfile}:${field_range%-*}${RESET}" \
      "${CYAN}# $example_index)" "${field_description}${RESET}"
  fi

  fatal_errors_set_if_empty "Fatal errors:${LF}"
  fatal_errors_append "$@"
  fatal_error_count=$((${fatal_error_count:-0} + 1))
}
