#shellcheck shell=sh

Describe "core/modifiers/length.sh"
  Before set_subject
  subject() { false; }

  Describe "length modifier"
    Example 'example'
      The length of value foobarbaz should equal 9
    End

    Context 'when subject is abcde'
      subject() { shellspec_puts abcde; }
      Example 'its length should equal 5'
        When invoke spy_shellspec_modifier length _modifier_
        The stdout should equal 5
      End
    End

    Context 'when subject is undefined'
      subject() { false; }
      Example 'cant get length'
        When invoke spy_shellspec_modifier length _modifier_
        The status should be failure
      End
    End

    Example 'output error if next modifier is missing'
      When invoke spy_shellspec_modifier length
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
