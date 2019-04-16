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

    Context 'when status is defined'
      status() { %- 123; }
      It 'uses status as subject'
        When invoke shellspec_subject status _modifier_
        The stdout should equal 123
      End
    End

    Context 'when status is undefind'
      It 'uses undefined as subject'
        When invoke shellspec_subject status _modifier_
        The status should be failure
      End
    End

    It 'outputs error if next word is missing'
      When invoke shellspec_subject status
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
