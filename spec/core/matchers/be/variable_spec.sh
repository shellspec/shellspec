#shellcheck shell=sh

Describe "core/matchers/be/variable.sh"
  Describe 'be defined matcher'
    Example 'example'
      Set var1=1
      Unset var2
      The variable var1 should be defined
      The variable var2 should not be defined
    End

    Example 'matches defined variable'
      Set SHELLSPEC_SUBJECT=
      When invoke matcher be defined
      The status should be success
    End

    Example 'not matches undefined variable'
      Unset SHELLSPEC_SUBJECT
      When invoke matcher be defined
      The status should be failure
    End

    Example 'output error if parameters count is invalid'
      When invoke matcher be defined foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be undefined matcher'
    Example 'example'
      Unset var1
      Set var2=1
      The variable var1 should be undefined
      The variable var2 should not be undefined
    End

    Example 'matches undefined variable'
      Unset SHELLSPEC_SUBJECT
      When invoke matcher be undefined
      The status should be success
    End

    Example 'not matches defined variable'
      Set SHELLSPEC_SUBJECT=
      When invoke matcher be undefined
      The status should be failure
    End

    Example 'output error if parameters count is invalid'
      When invoke matcher be undefined foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be present matcher'
    Example 'example'
      Set var1="x" var2=""
      The variable var1 should be present
      The variable var2 should not be present
    End

    Example 'matches non zero length string'
      Set SHELLSPEC_SUBJECT="x"
      When invoke matcher be present
      The status should be success
    End

    Example 'not matches zero length string'
      Set SHELLSPEC_SUBJECT=""
      When invoke matcher be present
      The status should be failure
    End

    Example 'not matches undefind variable'
      Unset SHELLSPEC_SUBJECT
      When invoke matcher be present
      The status should be failure
    End

    Example 'output error if parameters count is invalid'
      When invoke matcher be present foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be blank matcher'
    Example 'example'
      Set var1="" var2="x"
      The variable var1 should be blank
      The variable var2 should not be blank
    End

    Example 'matches zero length string'
      Set SHELLSPEC_SUBJECT=""
      When invoke matcher be blank
      The status should be success
    End

    Example 'matches undefind variable'
      Unset SHELLSPEC_SUBJECT
      When invoke matcher be blank
      The status should be success
    End

    Example 'not matches non zero length string'
      Set SHELLSPEC_SUBJECT="x"
      When invoke matcher be blank
      The status should be failure
    End

    Example 'output error if parameters count is invalid'
      When invoke matcher be blank foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End
End