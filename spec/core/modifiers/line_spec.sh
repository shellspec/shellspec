#shellcheck shell=sh

Describe "core/modifiers/line.sh"
  Before set_subject
  subject() { false; }

  Describe "line modifier"
    Example 'example'
      The line 1 of value foobarbaz should equal foobarbaz
    End

    Context 'when subject is "foo<LF>bar<LF>baz"'
      subject() { shellspec_puts "foo${LF}bar${LF}baz"; }
      Example 'second line should equal "bar"'
        When invoke spy_shellspec_modifier line 2 _modifier_
        The entire stdout should equal bar
      End
    End

    Context 'when subject is "foo<LF>"'
      subject() { shellspec_puts "foo${LF}"; }
      Example 'can not get second line'
        When invoke spy_shellspec_modifier line 2 _modifier_
        The status should be failure
      End
    End

    Context 'when subject is "foo<LF><LF>"'
      subject() { shellspec_puts "foo${LF}${LF}"; }
      Example 'second line should equal ""'
        When invoke spy_shellspec_modifier line 2 _modifier_
        The entire stdout should equal ""
      End
    End

    Context 'when subject is empty string'
      subject() { shellspec_puts ""; }
      Example 'can not get first line'
        When invoke spy_shellspec_modifier line 1 _modifier_
        The status should be failure
      End
    End

    Context 'when subject is "<LF>"'
      subject() { shellspec_puts "${LF}"; }
      Example 'first line should equal ""'
        When invoke spy_shellspec_modifier line 1 _modifier_
        The entire stdout should equal ""
      End
    End

    Context 'when subject is undefined'
      subject() { false; }
      Example 'cannot get first line'
        When invoke spy_shellspec_modifier line 2 _modifier_
        The status should be failure
      End
    End

    Example 'outputs error if value is not a number'
      When invoke spy_shellspec_modifier line ni
      The stderr should equal SYNTAX_ERROR_PARAM_TYPE
    End

    Example 'outputs error if value is missing'
      When invoke spy_shellspec_modifier line
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End

    Example 'outputs error if next word is missing'
      When invoke spy_shellspec_modifier line 2
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
