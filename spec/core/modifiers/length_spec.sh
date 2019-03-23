#shellcheck shell=sh

Describe "core/modifiers/length.sh"
  Before set_subject intercept_shellspec_modifier
  subject() { false; }

  Describe "length modifier"
    Example 'example'
      The length of value foobarbaz should equal 9
    End

    Context 'when subject is defined'
      subject() { shellspec_puts abcde; }
      It 'counts length'
        When invoke shellspec_modifier length _modifier_
        The stdout should equal 5
      End
    End

    Context 'when subject is undefined'
      subject() { false; }
      It 'can not counts length'
        When invoke shellspec_modifier length _modifier_
        The status should be failure
      End
    End

    It 'outputs error if next modifier is missing'
      When invoke shellspec_modifier length
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
