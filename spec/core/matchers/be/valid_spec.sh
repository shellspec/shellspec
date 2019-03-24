#shellcheck shell=sh

Describe "core/matchers/be/valid.sh"
  Before set_subject intercept_shellspec_matcher
  subject() { false; }

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

    Context 'when subject is 123'
      Def subject 123
      It 'matches'
        When invoke shellspec_matcher be valid as a number
        The stdout should equal "is:number 123"
      End
    End

    Context 'when subject is undefined'
      It 'does not match'
        When invoke shellspec_matcher be valid as number
        The stdout should equal "is:number "
      End
    End

    It 'outputs error if parameters count is invalid'
      When invoke shellspec_matcher be valid number foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
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

    Context 'when subject is foo_bar'
      Def subject "foo_bar"
      It 'matches'
        When invoke shellspec_matcher be valid as a funcname
        The stdout should equal "is:funcname foo_bar"
      End
    End

    Context 'when subject is undefined'
      It 'does not match'
        When invoke shellspec_matcher be valid as funcname
        The stdout should equal "is:funcname "
      End
    End

    It 'outputs error if parameters count is invalid'
      When invoke shellspec_matcher be valid funcname foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End
End
