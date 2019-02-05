#shellcheck shell=sh

Describe "core/matchers/satisfy.sh"
  check() { [ "$SHELLSPEC_SUBJECT" = "$1" ]; }

  Describe 'satisfy matcher'
    Example 'example'
      The value foo should satisfy check foo
      The value foo should not satisfy check bar
    End

    Example 'matches subject'
      Set SHELLSPEC_SUBJECT=foo
      When invoke matcher satisfy check foo
      The status should be success
    End

    Example 'not matches subject'
      Set SHELLSPEC_SUBJECT=foo
      When invoke matcher satisfy check bar
      The status should be failure
    End

    Example 'output error if parameters is missing'
      When invoke matcher satisfy
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End
End
