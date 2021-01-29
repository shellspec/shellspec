#shellcheck shell=sh

Describe "core/subjects/status.sh"
  BeforeRun set_status subject_mock

  Describe "status subject"
    Example 'example'
      foo() { return 12; }
      When call foo
      The status should equal 12
    End

    It 'uses status as subject when status is defined'
      status() { %- 123; }
      When run shellspec_subject_status _modifier_
      The stdout should equal 123
    End

    It 'uses undefined as subject when status is undefind'
      status() { false; }
      When run shellspec_subject_status _modifier_
      The status should be failure
    End

    It 'outputs an error if the next word is missing'
      status() { %- 123; }
      When run shellspec_subject_status
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
