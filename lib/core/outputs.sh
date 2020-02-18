#shellcheck shell=sh disable=SC2016

shellspec_output_METADATA() {
  shellspec_output_meta "shell:$SHELLSPEC_SHELL" \
    "shell_type:$SHELLSPEC_SHELL_TYPE" "shell_version:$SHELLSPEC_SHELL_VERSION"
}

shellspec_output_FINISHED() {
  shellspec_output_finished
}

shellspec_output_BEGIN() {
  shellspec_output_begin "specfile:$SHELLSPEC_SPECFILE"
}

shellspec_output_END() {
  shellspec_output_end "example_count:$SHELLSPEC_EXAMPLE_COUNT"
}

shellspec_output_EXAMPLE() {
  shellspec_output_example "id:${SHELLSPEC_EXAMPLE_ID:-}" \
    "block_no:${SHELLSPEC_BLOCK_NO:-}" "example_no:${SHELLSPEC_EXAMPLE_NO:-}" \
    "focused:${SHELLSPEC_FOCUSED:-}" "description:$SHELLSPEC_DESCRIPTION"
}

shellspec_output_EVALUATION() {
  shellspec_output_statement "tag:evaluation" "note:" "fail:" \
    "evaluation:$SHELLSPEC_EVALUATION"
}

shellspec_output_SKIP() {
  if [ "$SHELLSPEC_SKIP_REASON" ]; then
    set -- "conditional:y" "message:$SHELLSPEC_SKIP_REASON"
  else
    set -- "conditional:" "message:Temporarily skipped"
  fi
  shellspec_output_statement "tag:skip" "note:SKIPPED" "fail:" \
    "skipid:$SHELLSPEC_SKIP_ID" "$@"
}

shellspec_output_PENDING() {
  shellspec_output_statement "tag:pending" "note:PENDING" "fail:" \
     "pending:y" "message:${SHELLSPEC_PENDING_REASON:-No reason given}"
}

shellspec_output_NOT_IMPLEMENTED() {
  shellspec_output_statement "tag:pending" "note:PENDING" "fail:" \
    "pending:y" "message:Not yet implemented" "reason:Not yet implemented"
}

shellspec_output_EXPECTATION() {
  shellspec_output_statement "tag:warn" "note:WARNING" \
    "fail:${SHELLSPEC_WARNING_AS_FAILURE:+y}" \
    "message:Not found any expectation" "failure_message:"
}

shellspec_output_UNHANDLED_STATUS() {
  shellspec_output_statement "tag:warn" "note:WARNING" \
    "fail:${SHELLSPEC_WARNING_AS_FAILURE:+y}" \
    "message:It was exits with status non-zero but not found expectation"
  shellspec_output_raw_append "failure_message:status:" "$SHELLSPEC_STATUS"
}

shellspec_output_UNHANDLED_STDOUT() {
  shellspec_output_statement "tag:warn" "note:WARNING" \
    "fail:${SHELLSPEC_WARNING_AS_FAILURE:+y}" \
    "message:It was output to stdout but not found expectation"
  shellspec_output_raw_append "failure_message:stdout:" "$SHELLSPEC_STDOUT"
}

shellspec_output_UNHANDLED_STDERR() {
  shellspec_output_statement "tag:warn" "note:WARNING" \
    "fail:${SHELLSPEC_WARNING_AS_FAILURE:+y}" \
    "message:It was output to stderr but not found expectation"
  shellspec_output_raw_append "failure_message:stderr:" "$SHELLSPEC_STDERR"
}

shellspec_output_FAILED_BEFORE_EACH_HOOK() {
  shellspec_output_statement "tag:bad" "note:" "fail:y" \
    "message:Before hook '$SHELLSPEC_HOOK' failed"
  shellspec_output_raw_append "failure_message:The before hook registered" \
    "at line $SHELLSPEC_HOOK_LINENO returned $SHELLSPEC_HOOK_STATUS"
}

shellspec_output_FAILED_AFTER_EACH_HOOK() {
  shellspec_output_statement "tag:bad" "note:" "fail:y" \
    "message:After hook '$SHELLSPEC_HOOK' failed"
  shellspec_output_raw_append "failure_message:The after hook registered" \
    "at line $SHELLSPEC_HOOK_LINENO returned $SHELLSPEC_HOOK_STATUS"
}

shellspec_output_MATCHED() {
  shellspec_output_statement "tag:good" "note:" "fail:" \
    "message:$SHELLSPEC_EXPECTATION"
}

shellspec_output_UNMATCHED() {
  shellspec_output_statement "tag:bad" "note:" "fail:y" \
    "message:$SHELLSPEC_EXPECTATION"
}

shellspec_output_SYNTAX_ERROR() {
  shellspec_output_statement "tag:bad" "note:SYNTAX ERROR" "fail:y" \
    "message:${SHELLSPEC_EXPECTATION:-}"
  shellspec_output_raw_append "failure_message:${1:-unknown syntax error}"
}

shellspec_output_SYNTAX_ERROR_EVALUATION() {
  shellspec_output_statement "tag:bad" "note:" "fail:y" \
    "message:${SHELLSPEC_EVALUATION:-}"
  shellspec_output_raw_append "failure_message:${1:-unknown syntax error}"
}

shellspec_output_SYNTAX_ERROR_EXPECTATION() {
  shellspec_output_statement "tag:bad" "note:" "fail:y" \
    "message:${SHELLSPEC_EXPECTATION:-}"
  shellspec_output_raw_append "failure_message:${1:-unknown syntax error}"
}

shellspec_output_SYNTAX_ERROR_MATCHER_REQUIRED() {
  shellspec_output_statement "tag:bad" "note:" "fail:y" \
    "message:${SHELLSPEC_EXPECTATION:-}"
  shellspec_output_raw_append "failure_message:A word is required after" \
    "$(shellspec_output_syntax_name)." \
    "The correct word is one of the following."
  shellspec_output_following_words "shellspec_matcher"
}

shellspec_output_SYNTAX_ERROR_DISPATCH_FAILED() {
  shellspec_output_statement "tag:bad" "note:" "fail:y" \
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
  shellspec_output_statement "tag:bad" "note:" "fail:y" \
    "message:${SHELLSPEC_EXPECTATION:-}"
  shellspec_output_raw_append "failure_message:The next word of" \
    "'${1##*_}' should be one of the following."
  shellspec_output_following_words "$1"
}

shellspec_output_SYNTAX_ERROR_WRONG_PARAMETER_COUNT() {
  shellspec_output_statement "tag:bad" "note:" "fail:y" \
    "message:${SHELLSPEC_EXPECTATION:-}"
  shellspec_output_raw_append "failure_message:Wrong parameter $1 of" \
    "$(shellspec_output_syntax_name)"
}

shellspec_output_SYNTAX_ERROR_PARAM_TYPE() {
  shellspec_output_raw statement "tag:bad" "note:" "fail:y" \
    "message:${SHELLSPEC_EXPECTATION:-}"
  shellspec_output_raw_append "failure_message:The parameter #$1 of" \
    "$(shellspec_output_syntax_name) is not a $2"
}

shellspec_output_RESULT_ERROR() {
  shellspec_readfile SHELLSPEC_RESULT_ERROR "$2"
  set -- "result modifier error (exit status: $1)${SHELLSPEC_LF}" \
    "$SHELLSPEC_RESULT_ERROR${SHELLSPEC_LF}"
  shellspec_output_statement "tag:bad" "note:" "fail:y" \
    "message:${SHELLSPEC_EXPECTATION:-}" "failure_message:$1$2"
}

shellspec_output_ABORTED() {
  if [ -s "$SHELLSPEC_STDOUT_FILE" ]; then
    shellspec_readfile SHELLSPEC_STDOUT "$SHELLSPEC_STDOUT_FILE"
    set -- "$1" "${2:-}stdout:${SHELLSPEC_STDOUT}${SHELLSPEC_LF}"
  fi
  if [ -s "$SHELLSPEC_STDERR_FILE" ]; then
    shellspec_readfile SHELLSPEC_STDERR "$SHELLSPEC_STDERR_FILE"
    set -- "$1" "${2:-}stderr:${SHELLSPEC_STDERR}${SHELLSPEC_LF}"
  fi
  shellspec_output_statement "tag:bad" "note:" "fail:y" \
    "message:Example aborted (exit status: $1)" "failure_message:${2:-}"
}

shellspec_output_SUCCEEDED() {
  shellspec_output_result "tag:succeeded" "note:" "fail:"
}

shellspec_output_FAILED() {
  shellspec_output_result "tag:failed" "note:FAILED" "fail:y"
}

shellspec_output_WARNED() {
  shellspec_output_result "tag:warned" "note:WARNED" \
    "fail:${SHELLSPEC_WARNING_AS_FAILURE:+y}"
}

shellspec_output_TODO() {
  shellspec_output_result "tag:todo" "note:PENDING" "fail:"
}

shellspec_output_FIXED() {
  shellspec_output_result "tag:fixed" "note:FIXED" "fail:y"
}

shellspec_output_SKIPPED() {
  shellspec_output_result "tag:skipped" "note:SKIPPED" "fail:"
}
