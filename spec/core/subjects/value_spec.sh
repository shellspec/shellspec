#shellcheck shell=sh

Describe "core/subjects/value.sh"
  Describe "value subject"
    Example 'example'
      The value foo should equal foo
      The function foo should equal foo # alias for value
    End

    Example "use parameter as subject"
      When invoke spy_shellspec_subject value foo _modifier_
      The stdout should equal 'foo'
    End

    Example 'outputs error if value is missing'
      When invoke spy_shellspec_subject value
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End

    Example 'outputs error if next word is missing'
      When invoke spy_shellspec_subject value foo
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
