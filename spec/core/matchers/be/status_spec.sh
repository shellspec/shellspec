#shellcheck shell=sh

Describe "core/matchers/be/status.sh"
  BeforeRun set_subject matcher_mock

  Describe 'be success matcher'
    Example 'example'
      The value 0 should be success
      The value 1 should not be success
    End

    It 'matches 0'
      subject() { %- 0; }
      When run shellspec_matcher_be_success
      The status should be success
    End

    It 'does not match 1'
      subject() { %- 1; }
      When run shellspec_matcher_be_success
      The status should be failure
    End

    It 'does not match non numeric values'
      subject() { %- "a"; }
      When run shellspec_matcher_be_success
      The status should be failure
    End

    It 'does not match zero length string'
      subject() { %- ""; }
      When run shellspec_matcher_be_success
      The status should be failure
    End

    It 'does not match undefined'
      subject() { false; }
      When run shellspec_matcher_be_success
      The status should be failure
    End

    It 'outputs error if parameters count is invalid'
      subject() { %- 0; }
      When run shellspec_matcher_be_success foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End
  End

  Describe 'be failure matcher'
    Example 'example'
      The value 1 should be failure
      The value 0 should not be failure
    End

    It 'matches 1'
      subject() { %- 1; }
      When run shellspec_matcher_be_failure
      The status should be success
    End

    It 'does not match 0'
      subject() { %- 0; }
      When run shellspec_matcher_be_failure
      The status should be failure
    End

    It 'does not match -1'
      subject() { %- -1; }
      When run shellspec_matcher_be_failure
      The status should be failure
    End

    It 'matches 255'
      subject() { %- 255; }
      When run shellspec_matcher_be_failure
      The status should be success
    End

    It 'does not match 256'
      subject() { %- 256; }
      When run shellspec_matcher_be_failure
      The status should be failure
    End

    It 'does not match non numeric values'
      subject() { %- "a"; }
      When run shellspec_matcher_be_failure
      The status should be failure
    End

    It 'does not match zero length string'
      subject() { %- ""; }
      When run shellspec_matcher_be_failure
      The status should be failure
    End

    It 'does not match undefined'
      subject() { false; }
      When run shellspec_matcher_be_failure
      The status should be failure
    End

    It 'outputs error if parameters count is invalid'
      subject() { %- 1; }
      When run shellspec_matcher_be_failure foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End
  End
End