#shellcheck shell=sh disable=SC2016

shellspec_output_METADATA() {
  shellspec_output_raw meta "shell:$SHELLSPEC_SHELL" \
    "shell_type:$SHELLSPEC_SHELL_TYPE" "shell_version:$SHELLSPEC_SHELL_VERSION"
}

shellspec_output_FINISHED() {
  shellspec_output_raw finished
}

shellspec_output_BEGIN() {
  shellspec_output_raw begin "specfile:$SHELLSPEC_SPECFILE"
}

shellspec_output_END() {
  shellspec_output_raw end "example_count:$SHELLSPEC_EXAMPLE_COUNT"
}

shellspec_output_EXAMPLE() {
  shellspec_output_raw example "id:${SHELLSPEC_EXAMPLE_ID:-}" \
    "block_no:${SHELLSPEC_BLOCK_NO:-}" "focused:${SHELLSPEC_FOCUSED:-}" \
    "range:${SHELLSPEC_LINENO_BEGIN:-}-${SHELLSPEC_LINENO_END:-}" \
    "description:$SHELLSPEC_DESCRIPTION"
}

shellspec_output_EVALUATION() {
  shellspec_output_raw statement "tag:evaluation" \
    "evaluation:$SHELLSPEC_EVALUATION"
}

shellspec_output_SKIP() {
  if [ "${SHELLSPEC_SKIP_REASON:-}" ]; then
    set -- "message:Skipped because $SHELLSPEC_SKIP_REASON"
    SHELLSPEC_CONDITIONAL_SKIP=1
  else
    set -- "message:Temporarily skipped"
  fi
  shellspec_output_raw statement "tag:skip" "skipid:$SHELLSPEC_SKIP_ID" \
    "conditional:${SHELLSPEC_CONDITIONAL_SKIP:+yes}" "$@"
}

shellspec_output_PENDING() {
  shellspec_output_raw statement "tag:pending" "pending:yes" \
    "message:PENDING: ${SHELLSPEC_PENDING_REASON:-No reason given}"
}

shellspec_output_NOT_IMPLEMENTED() {
  shellspec_output_raw statement "tag:pending" "message:Not yet implemented"
}

shellspec_output_UNHANDLED_STATUS() {
  shellspec_output_raw statement "$@" "tag:bad" "note:" \
    "message:It was exits with status non-zero but not found expectation"
  shellspec_output_raw_append "failure_message:status:" "$SHELLSPEC_STATUS"
}

shellspec_output_UNHANDLED_STDOUT() {
  shellspec_output_raw statement "$@" "tag:bad" "note:" \
    "message:It was output to stdout but not found expectation"
  shellspec_output_raw_append "failure_message:stdout:" "$SHELLSPEC_STDOUT"
}

shellspec_output_UNHANDLED_STDERR() {
  shellspec_output_raw statement "$@" "tag:bad" "note:" \
    "message:It was output to stderr but not found expectation"
  shellspec_output_raw_append "failure_message:stderr:" "$SHELLSPEC_STDERR"
}

shellspec_output_FAILED_BEFORE_HOOK() {
  shellspec_output_raw statement "tag:bad" "note:" \
    "message:Before hook '$SHELLSPEC_HOOK' failed"
  shellspec_output_raw_append "failure_message:The before hook registered" \
    "at line $SHELLSPEC_HOOK_LINENO returned $SHELLSPEC_HOOK_STATUS"
}

shellspec_output_FAILED_AFTER_HOOK() {
  shellspec_output_raw statement "tag:bad" "note:" \
    "message:After hook '$SHELLSPEC_HOOK' failed"
  shellspec_output_raw_append "failure_message:The after hook registered" \
    "at line $SHELLSPEC_HOOK_LINENO returned $SHELLSPEC_HOOK_STATUS"
}

shellspec_output_MATCHED() {
  shellspec_output_raw statement "tag:good" "message:$SHELLSPEC_EXPECTATION"
}

shellspec_output_UNMATCHED() {
  shellspec_output_raw statement "tag:bad" "message:$SHELLSPEC_EXPECTATION"
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
  set -- "tag:bad" "message:${SHELLSPEC_EXPECTATION:-}"
  shellspec_output_raw statement "$@"
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
  shellspec_output_raw result "tag:succeeded" "note:" "fail:"
}

shellspec_output_FAILED() {
  shellspec_output_raw result "tag:failed" "note:FAILED" "fail:y"
}

shellspec_output_TODO() {
  shellspec_output_raw result "tag:todo" "note:PENDING" "fail:"
}

shellspec_output_FIXED() {
  shellspec_output_raw result "tag:fixed" "note:FIXED" "fail:y"
}

shellspec_output_SKIPPED() {
  shellspec_output_raw result "tag:skipped" "note:SKIPPED" "fail:"
}
