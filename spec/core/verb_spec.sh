# shellcheck shell=sh disable=SC2016,SC2286,SC2287,SC2288

Describe "core/verb.sh"
  mock() {
    shellspec_output() { echo "output:" "$@"; }
    shellspec_get_failure_message() { echo "$1" message; }
  }

  # shellcheck disable=SC2034
  inspect() {
    shellspec_if SYNTAX_ERROR && SYNTAX_ERROR=on || SYNTAX_ERROR=off
    shellspec_if FAILED && FAILED=on || FAILED=off
    %preserve FAILED SYNTAX_ERROR
  }

  BeforeRun mock
  AfterRun inspect

  Describe "should verb"
    It "outputs MATCHED if matcher matched"
      When run shellspec_verb_should _matched_
      The stdout should eq 'output: MATCHED'
      The variable SYNTAX_ERROR should eq 'off'
      The variable FAILED should eq 'off'
    End

    It "outputs UNMATCHED if matcher unmatched"
      When run shellspec_verb_should _unmatched_
      The output should eq 'output: UNMATCHED positive message'
      The variable SYNTAX_ERROR should eq 'off'
      The variable FAILED should eq 'on'
    End

    It "outputs SYNTAX_ERROR_MATCHER_REQUIRED if matcher missing"
      When run shellspec_verb_should
      The stdout should eq 'output: SYNTAX_ERROR_MATCHER_REQUIRED'
      The variable SYNTAX_ERROR should eq 'on'
      The variable FAILED should eq 'on'
    End

    It "returns if SYNTAX_ERROR"
      When run shellspec_verb_should _syntax_error_matcher_
      The variable SYNTAX_ERROR should eq 'on'
      The variable FAILED should eq 'on'
    End
  End

  Describe "should not verb"
    It "outputs UNMATCHED if matcher matched"
      When run shellspec_verb_should not _matched_
      The output should eq 'output: UNMATCHED negative message'
      The variable SYNTAX_ERROR should eq 'off'
      The variable FAILED should eq 'on'
    End

    It "outputs MATCHED if matcher unmatched"
      When run shellspec_verb_should not _unmatched_
      The stdout should eq 'output: MATCHED'
      The variable SYNTAX_ERROR should eq 'off'
      The variable FAILED should eq 'off'
    End

    It "outputs SYNTAX_ERROR_MATCHER_REQUIRED if matcher missing"
      When run shellspec_verb_should not
      The stdout should eq 'output: SYNTAX_ERROR_MATCHER_REQUIRED'
      The variable SYNTAX_ERROR should eq 'on'
      The variable FAILED should eq 'on'
    End

    It "returns if SYNTAX_ERROR"
      When run shellspec_verb_should _syntax_error_matcher_
      The variable SYNTAX_ERROR should eq 'on'
      The variable FAILED should eq 'on'
    End
  End
End
