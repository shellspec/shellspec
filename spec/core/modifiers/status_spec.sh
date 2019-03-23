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

    Context 'when subject is function that returns success'
      subject() { shellspec_puts ok; }
      It 'outputs success'
        When invoke shellspec_modifier status _modifier_
        The stdout should be success
      End
    End

    Context 'when subject is function that returns failure'
      subject() { shellspec_puts not_ok; }
      It 'outputs failure'
        When invoke shellspec_modifier status _modifier_
        The stdout should be failure
      End
    End

    Context 'when subject is undefined'
      subject() { false; }
      It 'does not outputs anything'
        When invoke shellspec_modifier status _modifier_
        The status should be failure
      End
    End

    It 'outputs error if next modifier is missing'
      When invoke shellspec_modifier status
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
