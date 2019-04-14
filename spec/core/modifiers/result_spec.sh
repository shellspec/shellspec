#shellcheck shell=sh

Describe "core/modifiers/result.sh"
  Before set_subject intercept_shellspec_modifier
  subject() { false; }

  Describe "result modifier"
    foo() { echo ok; true; }
    bar() { echo ok >&2; true; }

    Example 'example'
      The result of 'foo()' should equal ok
      The result of 'bar()' should equal ok # also capture stderr
    End

    Context 'when subject is function that returns success'
      Context 'when subject output to stdout'
        Def subject "success_with_stdout"
        success_with_stdout() { echo ok; true; }
        It 'gets stdout'
          When invoke shellspec_modifier result _modifier_
          The stdout should equal ok
        End
      End

      Context 'when subject output to stdout'
        Def subject "success_with_stderr"
        success_with_stderr() { echo ng >&2; true; }
        It 'gets stderr'
          When invoke shellspec_modifier result _modifier_
          The stdout should equal ng
        End
      End
    End

    Context 'when subject is function that returns failure'
      Context 'when subject output to stdout'
        Def subject "failure_with_stdout"
        failure_with_stdout() { echo ok; false; }
        It 'gets stdout'
          When invoke shellspec_modifier result _modifier_
          The status should be failure
          The stdout should be blank
        End
      End

      Context 'when subject output to stdout'
        Def subject "failure_with_stderr"
        failure_with_stderr() { echo ng >&2; false; }
        It 'gets stderr'
          When invoke shellspec_modifier result _modifier_
          The status should be failure
          The stderr should be blank
        End
      End
    End

    Context 'when subject is undefined'
      It 'can not calls function'
        When invoke shellspec_modifier result _modifier_
        The status should be failure
      End
    End

    It 'outputs error if next modifier is missing'
      When invoke shellspec_modifier result
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
