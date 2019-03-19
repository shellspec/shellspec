#shellcheck shell=sh

Describe "core/modifiers/output.sh"
  Describe "output modifier"
    Before set_subject
    subject() { false; }
    foo() { echo ok; }

    Example 'example'
      The output of value foo should equal ok
    End

    Context 'when subject is abcde'
      subject() { shellspec_puts foo; }
      Example 'its output should equal ok'
        When invoke spy_shellspec_modifier output _modifier_
        The stdout should equal ok
      End
    End

    Context 'when subject is undefined'
      subject() { false; }
      Example 'cant get output'
        When invoke spy_shellspec_modifier output _modifier_
        The status should be failure
      End
    End

    Example 'output error if next modifier is missing'
      When invoke spy_shellspec_modifier output
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
