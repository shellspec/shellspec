#shellcheck shell=sh

Describe "core/matchers/match.sh"
  Describe 'match matcher'
    Example 'example'
      The value "foobarbaz" should match "foo*"
      The value "foobarbaz" should not match "FOO*"
    End

    Example 'matches subject'
      Set SHELLSPEC_SUBJECT="foobarbaz"
      When invoke matcher match "foo*"
      The status should be success
    End

    Example 'not matches subject'
      Set SHELLSPEC_SUBJECT="foobarbaz"
      When invoke matcher match "FOO*"
      The status should be failure
    End

    Example 'not matches undefined subject'
      Unset SHELLSPEC_SUBJECT
      When invoke matcher match "*"
      The status should be failure
    End

    Example 'output error if parameters is missing'
      When invoke matcher match
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End

    Example 'output error if parameters count is invalid'
      When invoke matcher match "foo" "bar"
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End
End
