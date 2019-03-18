#shellcheck shell=sh

Describe "core/modifiers/word.sh"
  Describe "word modifier"
    Before set_subject
    subject() { false; }

    Example 'example'
      The word 2 of value "foo bar baz" should equal bar
    End

    Context 'when subject is "foo  bar <TAB> baz <LF> qux"'
      subject() { shellspec_puts "foo  bar $TAB baz $LF qux"; }

      Example 'second word is bar'
        When invoke modifier word 2 _modifier_
        The stdout should equal bar
      End

      Example 'third word is baz'
        When invoke modifier word 3 _modifier_
        The stdout should equal baz
      End

      Example 'fourth word is qux'
        When invoke modifier word 4 _modifier_
        The stdout should equal qux
      End
    End

    Context 'when subject is undefined'
      subject() { false; }
      Example 'can not get word'
        When invoke modifier word 1 _modifier_
        The status should be failure
      End
    End

    Example 'output error if value is not a number'
      When invoke modifier word ni _modifier_
      The stderr should equal SYNTAX_ERROR_PARAM_TYPE
    End

    Example 'output error if value is missing'
      When invoke modifier word
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End

    Example 'output error if next word is missing'
      When invoke modifier word 2
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
