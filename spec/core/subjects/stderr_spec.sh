#shellcheck shell=sh

Describe "core/subjects/stderr.sh"
  Describe "stderr subject"
    Example 'example'
      echo_to_stderr() { echo "foo" >&2; }
      When call echo_to_stderr
      The stderr should equal "foo"
      The error should equal "foo" # alias for stderr
    End

    Example "retrives SHELLSPEC_STDERR"
      Set SHELLSPEC_STDERR="test${SHELLSPEC_LF}"
      When invoke subject stderr _modifier_
      The entire stdout should equal 'test'
    End

    Example 'retrives undefined SHELLSPEC_STDERR'
      Unset SHELLSPEC_STDERR
      When invoke subject stderr _modifier_
      The status should be failure
    End

    Example 'output error if next word is missing'
      When invoke subject stderr
      The entire stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End

  Describe "entire stderr subject"
    Example 'example'
      echo_to_stderr() { echo "foo" >&2; }
      When call echo_to_stderr
      The entire stderr should equal "foo${SHELLSPEC_LF}"
      The entire error should equal "foo${SHELLSPEC_LF}"
    End

    Example "retrives SHELLSPEC_STDERR with newline"
      Set SHELLSPEC_STDERR="test${SHELLSPEC_LF}"
      When invoke subject entire stderr _modifier_
      The entire stdout should equal "test${SHELLSPEC_LF}"
    End

    Example 'retrives undefined SHELLSPEC_STDERR'
      Unset SHELLSPEC_STDERR
      When invoke subject entire stderr _modifier_
      The status should be failure
    End

    Example 'output error if next word is missing'
      When invoke subject entire stderr
      The entire stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
