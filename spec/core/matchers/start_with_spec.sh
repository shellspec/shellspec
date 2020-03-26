#shellcheck shell=sh

Describe "core/matchers/start_with.sh"
  BeforeRun set_subject matcher_mock

  Describe 'start with matcher'
    Example 'example'
      The value "foobarbaz" should start with "foo"
      The value "foobarbaz" should not start with "FOO"
    End

    It 'matches the string with same start'
      subject() { %- "abcdef"; }
      When run shellspec_matcher_start_with "abc"
      The status should be success
    End

    It 'does not matche with glob'
      subject() { %- "abcdef"; }
      When run shellspec_matcher_start_with "*"
      The status should be failure
    End

    It 'does not matches the string with different start'
      subject() { %- "abcdef"; }
      When run shellspec_matcher_start_with "ABC"
      The status should be failure
    End

    It 'does not matches undefined'
      subject() { false; }
      When run shellspec_matcher_start_with ""
      The status should be failure
    End

    It 'outputs error if parameters is missing'
      subject() { %- "abcdef"; }
      When run shellspec_matcher_start_with
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End

    It 'outputs error if parameters count is invalid'
      subject() { %- "abcdef"; }
      When run shellspec_matcher_start_with "foo" "bar"
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End
  End
End
