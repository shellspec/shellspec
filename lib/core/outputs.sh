#shellcheck shell=sh disable=SC2016

shellspec_output_METADATA() {
  shellspec_output_raw \
    "shell:$SHELLSPEC_SHELL" \
    "shell_type:$SHELLSPEC_SHELL_TYPE" \
    "shell_version:$SHELLSPEC_SHELL_VERSION"
}

shellspec_output_FLUSH() {
  shellspec_putsn
}

shellspec_output_SPECFILE_BEGIN() {
  shellspec_output_raw "type:begin" "tag:specfile" \
    "specfile:${SHELLSPEC_SPECFILE:-}"
}

shellspec_output_SPECFILE_END() {
  shellspec_output_raw "type:end" "tag:specfile" \
    "specfile:${SHELLSPEC_SPECFILE:-}"
}

shellspec_output_EXAMPLE_GROUP_BEGIN() {
  shellspec_output_raw begin "tag:example_group"
}

shellspec_output_EXAMPLE_GROUP_END() {
  shellspec_output_raw end "tag:example_group"
}

shellspec_output_EXAMPLE_BEGIN() {
  shellspec_output_raw begin "tag:example"
}

shellspec_output_EXAMPLE_END() {
  shellspec_output_raw end "tag:example"
}

shellspec_output_SKIP() {
  if [ "${SHELLSPEC_SKIP_REASON:-}" ]; then
    set -- "message:Skipped because $SHELLSPEC_SKIP_REASON"
    SHELLSPEC_CONDITIONAL_SKIP=1
  else
    set -- "message:Temporarily skipped"
  fi
  shellspec_output_raw statement "tag:skip" "skipid:${SHELLSPEC_SKIP_ID}" \
    "conditional:${SHELLSPEC_CONDITIONAL_SKIP:+yes}" "$@"
}

shellspec_output_PENDING() {
  shellspec_output_raw statement "tag:pending" \
    "message:PENDING: ${SHELLSPEC_PENDING_REASON:-No reason given}"
}

shellspec_output_NOT_IMPLEMENTED() {
  shellspec_output_raw statement "tag:pending" "message:Not yet implemented"
}

shellspec_output_UNHANDLED_STATUS() {
  case $SHELLSPEC_WARNINGS in
    none) return 0;;
    notice | error) set -- "tag:warn" ;;
    failure) set -- "tag:bad" ;;
  esac
  shellspec_output_raw statement "$@" \
    "message:It was exits with status non-zero but not found expectation"
  shellspec_output_raw_append "failure_message:status:" \
    "$SHELLSPEC_STATUS"
}

shellspec_output_UNHANDLED_STDOUT() {
  case $SHELLSPEC_WARNINGS in
    none) return 0;;
    notice | error) set -- "tag:warn" ;;
    failure) set -- "tag:bad" ;;
  esac
  shellspec_output_raw statement "$@" \
    "message:It was output to stdout but not found expectation"
  shellspec_output_raw_append "failure_message:stdout:" \
    "$SHELLSPEC_STDOUT"
}

shellspec_output_UNHANDLED_STDERR() {
  case $SHELLSPEC_WARNINGS in
    none) return 0;;
    notice | error) set -- "tag:warn" ;;
    failure) set -- "tag:bad" ;;
  esac
  shellspec_output_raw statement "$@" \
    "message:It was output to stderr but not found expectation"
  shellspec_output_raw_append "failure_message:stderr:" \
    "$SHELLSPEC_STDERR"
}

shellspec_output_EVALUATION() {
  set -- "tag:evaluation"
  shellspec_output_raw statement "$@"
}

shellspec_output_FAILED_BEFORE_HOOK() {
  set -- "tag:bad" "message:Before hook '$SHELLSPEC_HOOK' failed"
  shellspec_output_raw statement "$@"
  shellspec_output_raw_append "failure_message:The before hook registered" \
    "at line $SHELLSPEC_HOOK_LINENO returned $SHELLSPEC_HOOK_STATUS"
}

shellspec_output_FAILED_AFTER_HOOK() {
  set -- "tag:bad" "message:After hook '$SHELLSPEC_HOOK' failed"
  shellspec_output_raw statement "$@"
  shellspec_output_raw_append "failure_message:The after hook registered" \
    "at line $SHELLSPEC_HOOK_LINENO returned $SHELLSPEC_HOOK_STATUS"
}

shellspec_output_MATCHED() {
  set -- "tag:good" "message:$SHELLSPEC_EXPECTATION"
  shellspec_if FIXED && set -- "pending:yes" "note:FIXED" "$@"
  shellspec_output_raw statement "$@"
}

shellspec_output_UNMATCHED() {
  set -- "tag:bad" "message:$SHELLSPEC_EXPECTATION"
  shellspec_if TODO && set -- "pending:yes" "$@"
  shellspec_output_raw statement "$@"
}

shellspec_output_SYNTAX_ERROR() {
  shellspec_output_raw statement "tag:bad" \
    "message:[SYNTAX ERROR] ${SHELLSPEC_EXPECTATION:-}"
  shellspec_output_raw_append "failure_message:${1:-unknown syntax error}"
}

shellspec_output_SYNTAX_ERROR_EVALUATION() {
  shellspec_output_raw statement "tag:bad" \
    "message:${SHELLSPEC_EVALUATION:-}"
  shellspec_output_raw_append "failure_message:${1:-unknown syntax error}"
}

shellspec_output_SYNTAX_ERROR_EXPECTATION() {
  shellspec_output_raw statement "tag:bad" \
    "message:${SHELLSPEC_EXPECTATION:-}"
  shellspec_output_raw_append "failure_message:${1:-unknown syntax error}"
}

shellspec_output_SYNTAX_ERROR_MATCHER_REQUIRED() {
  shellspec_output_raw statement "tag:bad" \
    "message:${SHELLSPEC_EXPECTATION:-}"
  shellspec_output_raw_append "failure_message:A word is required after" \
    "$(shellspec_output_syntax_name)." \
    "The correct word is one of the following."
  shellspec_output_following_words "shellspec_matcher"
}

shellspec_output_SYNTAX_ERROR_DISPATCH_FAILED() {
  shellspec_output_raw statement "tag:bad" \
    "message:${SHELLSPEC_EXPECTATION:-}"
  [ "$1" = modifier ] && set -- "$1/verb" "${2:-}"
  if [ "${2:-}" ]; then
    shellspec_output_raw_append "failure_message:Unknown word '$2' after" \
      "$(shellspec_output_syntax_name)." \
      "The correct word is one of the following."
  else
    shellspec_output_raw_append "failure_message:A word is required after" \
      "$(shellspec_output_syntax_name)." \
      "The correct word is one of the following."
  fi
  shellspec_output_following_words "shellspec_${1%/verb}"
}

shellspec_output_SYNTAX_ERROR_COMPOUND_WORD() {
  shellspec_output_raw statement "tag:bad" \
    "message:${SHELLSPEC_EXPECTATION:-}"
  shellspec_output_raw_append "failure_message:The next word of" \
    "'${1##*_}' should be one of the following."
  shellspec_output_following_words "$1"
}

shellspec_output_SYNTAX_ERROR_WRONG_PARAMETER_COUNT() {
  shellspec_output_raw statement "tag:bad" \
    "message:${SHELLSPEC_EXPECTATION:-}"
  shellspec_output_raw_append "failure_message:Wrong parameter $1 of" \
    "$(shellspec_output_syntax_name)"
}

shellspec_output_SYNTAX_ERROR_PARAM_TYPE() {
  shellspec_output_raw statement "tag:bad" \
    "message:${SHELLSPEC_EXPECTATION:-}"
  shellspec_output_raw_append "failure_message:The parameter #$1 of" \
    "$(shellspec_output_syntax_name) is not a $2"
}

shellspec_output_SUCCEEDED() {
  shellspec_output_raw result "tag:succeeded"
}

shellspec_output_FAILED() {
  shellspec_output_raw result "tag:failed" "note:FAILED" "error:yes"
}

shellspec_output_WARNED() {
  case $SHELLSPEC_WARNINGS in
    none) set -- "tag:succeeded" ;;
    notice) set -- "tag:warned" "note:WARNED" ;;
    error) set -- "tag:warned" "note:WARNED"  "error:yes" ;;
    failure) set -- "tag:failed" "note:FAILED"  "error:yes" ;;
  esac
  shellspec_output_raw result "$@"
}

shellspec_output_TODO() {
  shellspec_output_raw result "tag:todo" "note:PENDING"
}

shellspec_output_FIXED() {
  shellspec_output_raw result "tag:fixed" "error:yes" "note:FIXED"
}

shellspec_output_SKIPPED() {
  shellspec_output_raw result "tag:skipped" "skipid:${SHELLSPEC_SKIP_ID:-}" \
    "conditional:${SHELLSPEC_CONDITIONAL_SKIP:+yes}" "note:SKIPPED"
}

shellspec_output_LOG() {
  shellspec_output_raw statement "tag:log" "message:${*:-}"
}
