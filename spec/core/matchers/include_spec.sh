#shellcheck shell=sh

Describe "core/matchers/include.sh"
  Describe 'include matcher'
    Example 'example'
      The value "foobarbaz" should include "bar"
      The value "foobarbaz" should not include "BAR"
    End

    Example 'matches subject'
      Set SHELLSPEC_SUBJECT="foo${SHELLSPEC_LF}bar${SHELLSPEC_LF}baz"
      When invoke matcher include "bar"
      The status should be success
    End

    Example 'not matches subject'
      Set SHELLSPEC_SUBJECT="foo${SHELLSPEC_LF}BAR${SHELLSPEC_LF}baz"
      When invoke matcher include "bar"
      The status should be failure
    End

    Example 'output error if parameters is missing'
      When invoke matcher include
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End

    Example 'output error if parameters count is invalid'
      When invoke matcher include "foo" "bar"
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End
End
