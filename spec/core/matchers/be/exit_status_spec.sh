#shellcheck shell=sh

Describe "core/matchers/be/exit_status.sh"
  Describe 'be success matcher'
    Example 'example'
      The value 0 should be success
      The value 1 should not be success
    End

    Example 'matches 0'
      Set SHELLSPEC_SUBJECT=0
      When invoke matcher be success
      The status should be success
    End

    Example 'not matches 1'
      Set SHELLSPEC_SUBJECT=1
      When invoke matcher be success
      The status should be failure
    End

    Example 'not matches non number values'
      Set SHELLSPEC_SUBJECT=a
      When invoke matcher be success
      The status should be failure
    End

    Example 'not matches zero length string'
      Set SHELLSPEC_SUBJECT=
      When invoke matcher be success
      The status should be failure
    End

    Example 'not matches undefined variable'
      Unset SHELLSPEC_SUBJECT
      When invoke matcher be success
      The status should be failure
    End

    Example 'output error if parameters count is invalid'
      When invoke matcher be success foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be failure matcher'
    Example 'example'
      The value 1 should be failure
      The value 0 should not be failure
    End

    Example 'matches 1'
      Set SHELLSPEC_SUBJECT=1
      When invoke matcher be failure
      The status should be success
    End

    Example 'not matches 0'
      Set SHELLSPEC_SUBJECT=0
      When invoke matcher be failure
      The status should be failure
    End

    Example 'not matches -1'
      Set SHELLSPEC_SUBJECT=-1
      When invoke matcher be failure
      The status should be failure
    End

    Example 'matches 255'
      Set SHELLSPEC_SUBJECT=255
      When invoke matcher be failure
      The status should be success
    End

    Example 'not matches value >= 256'
      Set SHELLSPEC_SUBJECT=256
      When invoke matcher be failure
      The status should be failure
    End

    Example 'not matches non numeric values'
      Set SHELLSPEC_SUBJECT=a
      When invoke matcher be failure
      The status should be failure
    End

    Example 'not matches zero length string'
      Set SHELLSPEC_SUBJECT=
      When invoke matcher be failure
      The status should be failure
    End

    Example 'not matches undefined variable'
      Unset SHELLSPEC_SUBJECT
      When invoke matcher be failure
      The status should be failure
    End

    Example 'output error if parameters count is invalid'
      When invoke matcher be failure foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End
End