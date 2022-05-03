# shellcheck shell=sh disable=SC2016,SC2286,SC2287,SC2288

Describe "core/matchers/be/valid.sh"
  BeforeRun set_subject matcher_mock

  Describe 'be a number matcher'
    Example 'example'
      The value "123" should be valid number
      The value "123" should be a valid number
      The value "123" should be valid as number
      The value "123" should be valid as a number
      The value "abc" should not be valid number
      The value "abc" should not be a valid number
      The value "abc" should not be valid as number
      The value "abc" should not be valid as a number
    End

    It 'matches number'
      subject() { %- 123; }
      When run shellspec_matcher_be_valid_number
      The status should be success
    End

    It 'does not match non-number'
      subject() { %- 123a; }
      When run shellspec_matcher_be_valid_number
      The status should be failure
    End

    It 'does not match undefined'
      subject() { false; }
      When run shellspec_matcher_be_valid_number
      The status should be failure
    End

    It 'outputs error if parameters count is invalid'
      subject() { %- 123; }
      When run shellspec_matcher_be_valid_number foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End
  End

  Describe 'be a funcname matcher'
    Example 'example'
      The value "foo" should be valid funcname
      The value "foo" should be a valid funcname
      The value "foo" should be valid as funcname
      The value "foo" should be valid as a funcname
      The value "123" should not be valid funcname
      The value "123" should not be a valid funcname
      The value "123" should not be valid as funcname
      The value "123" should not be valid as a funcname
    End

    It 'matches function name'
      subject() { %- "foo_bar"; }
      When run shellspec_matcher_be_valid_funcname
      The status should be success
    End

    It 'does not match undefined'
      subject() { false; }
      When run shellspec_matcher_be_valid_funcname
      The status should be failure
    End

    It 'outputs error if parameters count is invalid'
      subject() { %- "foo_bar"; }
      When run shellspec_matcher_be_valid_funcname foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End
  End
End
