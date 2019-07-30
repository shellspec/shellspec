#shellcheck shell=sh

Describe "core/matchers/match.sh"
  BeforeRun set_subject matcher_mock

  Describe 'match matcher'
    Example 'example'
      The value "foobarbaz" should match "foo*"
      The value "foobarbaz" should not match "FOO*"
    End

    It 'match a string containing a pattern'
      subject() { %- "foobarbaz"; }
      When run shellspec_matcher_match "foo*"
      The status should be success
    End

    It 'does not match a string not containing a pattern'
      subject() { %- "foobarbaz"; }
      When run shellspec_matcher_match "FOO*"
      The status should be failure
    End

    It 'does not match undefined'
      subject() { false; }
      When run shellspec_matcher_match "*"
      The status should be failure
    End

    It 'outputs error if parameters is missing'
      subject() { %- "foobarbaz"; }
      When run shellspec_matcher_match
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End

    It 'outputs error if parameters count is invalid'
      subject() { %- "foobarbaz"; }
      When run shellspec_matcher_match "foo" "bar"
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End
  End
End
