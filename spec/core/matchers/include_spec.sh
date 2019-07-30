#shellcheck shell=sh

Describe "core/matchers/include.sh"
  BeforeRun set_subject matcher_mock

  Describe 'include matcher'
    Example 'example'
      The value "foobarbaz" should include "bar"
      The value "foobarbaz" should not include "BAR"
    End

    It 'matches that include string'
      subject() { %= "foo${LF}bar${LF}baz"; }
      When run shellspec_matcher_include "bar"
      The status should be success
    End

    It 'does not matches that not include string'
      subject() { %= "foo${LF}BAR${LF}baz"; }
      When run shellspec_matcher_include "bar"
      The status should be failure
    End

    It 'does not matches undefined'
      subject() { false; }
      When run shellspec_matcher_include ""
      The status should be failure
    End

    It 'outputs error if parameters is missing'
      subject() { %= "foo${LF}bar${LF}baz"; }
      When run shellspec_matcher_include
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End

    It 'outputs error if parameters count is invalid'
      subject() { %= "foo${LF}bar${LF}baz"; }
      When run shellspec_matcher_include "foo" "bar"
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End
  End
End
