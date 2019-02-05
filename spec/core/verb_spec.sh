#shellcheck shell=sh

Describe "core/verb.sh"
  should() {
    shellspec_output() { echo "[$1]"; }
    shellspec_output_failure_message() { echo message; }
    shellspec_output_failure_message_when_negated() { echo negated_message; }
    eval shellspec_verb_should ${1+'"$@"'}
    shellspec_if SYNTAX_ERROR && echo "syntax error" || echo "syntax ok"
    shellspec_if FAILED && echo "failed" || echo "succeeded"
  }

  Describe "should verb"
    Example "outputs MATCHED when matcher matched"
      When invoke should _matched_
      The first line of stdout should equal '[MATCHED]'
      The second line of stdout should equal 'syntax ok'
      The third line of stdout should equal 'succeeded'
    End

    Example "outputs UNMATCHED when matcher unmatched"
      When invoke should _unmatched_
      The first line of stdout should equal '[UNMATCHED]'
      The second line of stdout should equal "message"
      The third line of stdout should equal 'syntax ok'
      The fourth line of stdout should equal 'failed'
    End

    Example "outputs SYNTAX_ERROR_MATCHER_REQUIRED when matcher missing"
      When invoke should
      The first line of stdout should equal '[SYNTAX_ERROR_MATCHER_REQUIRED]'
      The second line of stdout should equal 'syntax error'
      The third line of stdout should equal 'failed'
    End

    Example "return if SYNTAX_ERROR"
      When invoke should _syntax_error_matcher_
      The first line of stdout should equal 'syntax error'
      The second line of stdout should equal 'failed'
    End
  End

  Describe "should not verb"
    Example "outputs UNMATCHED when matcher matched"
      When invoke should not _matched_
      The first line of stdout should equal '[UNMATCHED]'
      The second line of stdout should equal 'negated_message'
      The third line of stdout should equal 'syntax ok'
      The fourth line of stdout should equal 'failed'
    End

    Example "outputs MATCHED when matcher unmatched"
      When invoke should not _unmatched_
      The first line of stdout should equal '[MATCHED]'
      The second line of stdout should equal 'syntax ok'
      The third line of stdout should equal 'succeeded'
    End

    Example "outputs SYNTAX_ERROR_MATCHER_REQUIRED when matcher missing"
      When invoke should not
      The first line of stdout should equal '[SYNTAX_ERROR_MATCHER_REQUIRED]'
      The second line of stdout should equal 'syntax error'
      The third line of stdout should equal 'failed'
    End

    Example "return if SYNTAX_ERROR"
      When invoke should _syntax_error_matcher_
      The first line of stdout should equal 'syntax error'
      The second line of stdout should equal 'failed'
    End
  End
End
