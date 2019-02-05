#shellcheck shell=sh

Describe "core/subjects/stdout.sh"
  Describe "stdout subject"
    Example 'example'
      echo_to_stdout() { echo "foo"; }
      When call echo_to_stdout
      The stdout should equal "foo"
      The output should equal "foo" # alias for stdout
    End

    Example "retrives SHELLSPEC_STDOUT"
      Set SHELLSPEC_STDOUT="test${SHELLSPEC_LF}"
      When invoke subject stdout _modifier_
      The entire stdout should equal 'test'
    End

    Example 'retrives undefined SHELLSPEC_STDOUT'
      Unset SHELLSPEC_STDOUT
      When invoke subject stdout _modifier_
      The status should be failure
    End

    Example 'output outor if next word is missing'
      When invoke subject stdout
      The entire stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End

  Describe "entire stdout subject"
    Example 'example'
      echo_to_stdout() { echo "foo"; }
      When call echo_to_stdout
      The entire stdout should equal "foo${SHELLSPEC_LF}"
      The entire output should equal "foo${SHELLSPEC_LF}" # alias for entire stdout
    End

    Example "retrives SHELLSPEC_STDOUT with newline"
      Set SHELLSPEC_STDOUT="test${SHELLSPEC_LF}"
      When invoke subject entire stdout _modifier_
      The entire stdout should equal "test${SHELLSPEC_LF}"
    End

    Example 'retrives undefined SHELLSPEC_STDOUT'
      Unset SHELLSPEC_STDOUT
      When invoke subject entire stdout _modifier_
      The status should be failure
    End

    Example 'output outor if next word is missing'
      When invoke subject entire stdout
      The entire stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
