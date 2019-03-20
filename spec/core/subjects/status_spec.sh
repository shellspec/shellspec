#shellcheck shell=sh

Describe "core/subjects/status.sh"
  Before set_status intercept_shellspec_subject
  status() { false; }

  Describe "status subject"
    Example 'example'
      func() { return 12; }
      When call func
      The status should equal 12
    End

    Context 'when status is 123'
      status() { shellspec_puts 123; }
      Example 'should equal 123'
        When invoke shellspec_subject status _modifier_
        The stdout should equal 123
      End
    End

    Context 'when status is undefind'
      status() { false; }
      Example 'should be failure'
        When invoke shellspec_subject status _modifier_
        The status should be failure
      End
    End

    Example 'outputs error if next word is missing'
      When invoke shellspec_subject status
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
