#shellcheck shell=sh

Describe "core/matchers/start_with.sh"
  Describe 'start with matcher'
    Example 'example'
      The value "foobarbaz" should start with "foo"
      The value "foobarbaz" should not start with "FOO"
    End

    Example 'matches subject'
      Set SHELLSPEC_SUBJECT=abcdef
      When invoke matcher start with "abc"
      The status should be success
    End

    Example 'not matches subject'
      Set SHELLSPEC_SUBJECT=ABCDEF
      When invoke matcher start with "abc"
      The status should be failure
    End

    Example 'output error if parameters is missing'
      When invoke matcher start with
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End

    Example 'output error if parameters count is invalid'
      When invoke matcher start with "foo" "bar"
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End
End
