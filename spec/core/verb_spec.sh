#shellcheck shell=sh

Describe "core/verb.sh"
  shellspec_around_invoke() {
    shellspec_output() { echo "output:$1"; }
    shellspec_output_failure_message() { echo message; }
    shellspec_output_failure_message_when_negated() { echo negated_message; }
    "$@"
    shellspec_if SYNTAX_ERROR && echo "SYNTAX_ERROR:on" || echo "SYNTAX_ERROR:off"
    shellspec_if FAILED && echo "FAILED:on" || echo "FAILED:off"
  }

  Describe "should verb"
    It "outputs MATCHED if matcher matched"
      When invoke shellspec_verb_should _matched_
      The stdout should include 'output:MATCHED'
      The stdout should include 'SYNTAX_ERROR:off'
      The stdout should include 'FAILED:off'
    End

    It "outputs UNMATCHED if matcher unmatched"
      When invoke shellspec_verb_should _unmatched_
      The stdout should include 'output:UNMATCHED'
      The stdout should include "message"
      The stdout should include 'SYNTAX_ERROR:off'
      The stdout should include 'FAILED:on'
    End

    It "outputs SYNTAX_ERROR_MATCHER_REQUIRED if matcher missing"
      When invoke shellspec_verb_should
      The stdout should include 'output:SYNTAX_ERROR_MATCHER_REQUIRED'
      The stdout should include 'SYNTAX_ERROR:on'
      The stdout should include 'FAILED:on'
    End

    It "returns if SYNTAX_ERROR"
      When invoke shellspec_verb_should _syntax_error_matcher_
      The stdout should include 'SYNTAX_ERROR:on'
      The stdout should include 'FAILED:on'
    End
  End

  Describe "should not verb"
    It "outputs UNMATCHED if matcher matched"
      When invoke shellspec_verb_should not _matched_
      The stdout should include 'output:UNMATCHED'
      The stdout should include 'negated_message'
      The stdout should include 'SYNTAX_ERROR:off'
      The stdout should include 'FAILED:on'
    End

    It "outputs MATCHED if matcher unmatched"
      When invoke shellspec_verb_should not _unmatched_
      The stdout should include 'output:MATCHED'
      The stdout should include 'SYNTAX_ERROR:off'
      The stdout should include 'FAILED:off'
    End

    It "outputs SYNTAX_ERROR_MATCHER_REQUIRED if matcher missing"
      When invoke shellspec_verb_should not
      The stdout should include 'output:SYNTAX_ERROR_MATCHER_REQUIRED'
      The stdout should include 'SYNTAX_ERROR:on'
      The stdout should include 'FAILED:on'
    End

    It "returns if SYNTAX_ERROR"
      When invoke shellspec_verb_should _syntax_error_matcher_
      The stdout should include 'SYNTAX_ERROR:on'
      The stdout should include 'FAILED:on'
    End
  End
End
