#shellcheck shell=sh

Describe "core/subjects/exit_status.sh"
  Describe "exit status subject"
    Before set_exit_status
    exit_status() { false; }

    Example 'example'
      func() { return 12; }
      When call func
      The exit status should equal 12
      The status should equal 12 # alias for exit status
    End

    Context 'when exit status is 123'
      exit_status() { shellspec_puts 123; }
      Example 'it should equal 123'
        When invoke subject exit status _modifier_
        The stdout should equal 123
      End
    End

    Context 'when exit status is undefind'
      exit_status() { false; }
      Example 'it should be failure'
        When invoke subject exit status _modifier_
        The status should be failure
      End
    End

    Example 'output error if next word is missing'
      When invoke subject exit status
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
