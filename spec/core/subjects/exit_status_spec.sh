#shellcheck shell=sh

Describe "core/subjects/exit_status.sh"
  Describe "exit status subject"
    Example 'example'
      exit_status() { return 12; }
      When call exit_status
      The exit status should equal 12
      The status should equal 12 # alias for exit status
    End

    Example 'retrives SHELLSPEC_EXIT_STATUS'
      Set SHELLSPEC_EXIT_STATUS=123
      When invoke subject exit status _modifier_
      The stdout should equal 123
    End

    Example 'retrives undefined SHELLSPEC_EXIT_STATUS'
      Unset SHELLSPEC_EXIT_STATUS
      When invoke subject exit status _modifier_
      The status should be failure
    End

    Example 'output error if next word is missing'
      When invoke subject exit status
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
