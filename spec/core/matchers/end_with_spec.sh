#shellcheck shell=sh

Describe "core/matchers/end_with.sh"
  BeforeRun set_subject matcher_mock

  Describe "end with matcher"
    Example 'example'
      The value "foobarbaz" should end with "baz"
      The value "foobarbaz" should not end with "BAZ"
    End

    It 'matches the string with same end'
      subject() { %- "abcdef"; }
      When run shellspec_matcher_end_with "def"
      The status should be success
    End

    It 'does not matches the string with different end'
      subject() { %- "abcdef"; }
      When run shellspec_matcher_end_with "DEF"
      The status should be failure
    End

    It 'does not matches undefined'
      subject() { false; }
      When run shellspec_matcher_end_with ""
      The status should be failure
    End

    It 'outputs error if parameters is missing'
      subject() { %- "abcdef"; }
      When run shellspec_matcher_end_with
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End

    It 'outputs error if parameters count is invalid'
      subject() { %- "abcdef"; }
      When run shellspec_matcher_end_with "foo" "bar"
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End
  End
End
