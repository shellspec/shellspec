#shellcheck shell=sh

Describe "core/modifiers/output.sh"
  Before set_subject intercept_shellspec_modifier
  subject() { false; }

  Describe "output modifier"
    foo() { shellspec_puts ok; }

    Example 'example'
      The output of 'foo()' should equal ok
    End

    Context 'when subject is abcde'
      subject() { shellspec_puts foo; }
      Example 'its output should equal "ok"'
        When invoke shellspec_modifier output _modifier_
        The stdout should equal ok
      End
    End

    Context 'when subject is undefined'
      subject() { false; }
      Example 'cannot get output'
        When invoke shellspec_modifier output _modifier_
        The status should be failure
      End
    End

    Example 'outputs error if next modifier is missing'
      When invoke shellspec_modifier output
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
