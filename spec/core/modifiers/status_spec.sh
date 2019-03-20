#shellcheck shell=sh

Describe "core/modifiers/status.sh"
  Before set_subject intercept_shellspec_modifier
  subject() { false; }

  Describe "status modifier"
    foo() { true; }
    ok() { true; }
    not_ok() { false; }

    Example 'example'
      The status of 'foo()' should be success
    End

    Context 'when subject is ok'
      subject() { shellspec_puts ok; }
      Example 'its status should be success'
        When invoke shellspec_modifier status _modifier_
        The stdout should be success
      End
    End

    Context 'when subject is not_ok'
      subject() { shellspec_puts not_ok; }
      Example 'its status should be success'
        When invoke shellspec_modifier status _modifier_
        The stdout should be failure
      End
    End

    Context 'when subject is undefined'
      subject() { false; }
      Example 'cannot get status'
        When invoke shellspec_modifier status _modifier_
        The status should be failure
      End
    End

    Example 'outputs error if next modifier is missing'
      When invoke shellspec_modifier status
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
