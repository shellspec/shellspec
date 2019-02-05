#shellcheck shell=sh

Describe "core/matchers/be/valid.sh"
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

    Example 'call shellspec_is number'
      Set SHELLSPEC_SUBJECT=123
      When invoke matcher be valid as a number
      The stdout should equal "is:number 123"
    End

    Example 'call shellspec_is number with undefined subject'
      Unset SHELLSPEC_SUBJECT
      When invoke matcher be valid as number
      The stdout should equal "is:number "
    End

    Example 'output error if parameters count is invalid'
      When invoke matcher be valid number foo
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

    Example 'call shellspec_is function'
      Set SHELLSPEC_SUBJECT=foo_bar
      When invoke matcher be valid as a funcname
      The stdout should equal "is:funcname foo_bar"
    End

    Example 'call shellspec_is function with undefined subject'
      Unset SHELLSPEC_SUBJECT
      When invoke matcher be valid as funcname
      The stdout should equal "is:funcname "
    End

    Example 'output error if parameters count is invalid'
      When invoke matcher be valid funcname foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End
End
