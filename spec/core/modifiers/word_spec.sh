#shellcheck shell=sh

Describe "core/modifiers/word.sh"
  Before set_subject intercept_shellspec_modifier
  subject() { false; }

  Describe "word modifier"
    Example 'example'
      The word 2 of value "foo bar baz" should equal bar
    End

    Context 'when subject is "foo  bar <TAB> baz <LF> qux"'
      subject() { shellspec_puts "foo  bar $TAB baz $LF qux"; }

      Example 'second word should equal "bar"'
        When invoke shellspec_modifier word 2 _modifier_
        The stdout should equal bar
      End

      Example 'third word should equal "baz"'
        When invoke shellspec_modifier word 3 _modifier_
        The stdout should equal baz
      End

      Example 'fourth word should equal "qux"'
        When invoke shellspec_modifier word 4 _modifier_
        The stdout should equal qux
      End
    End

    Context 'when subject is undefined'
      subject() { false; }
      Example 'cannot get word'
        When invoke shellspec_modifier word 1 _modifier_
        The status should be failure
      End
    End

    Example 'outputs error if value is not a number'
      When invoke shellspec_modifier word ni _modifier_
      The stderr should equal SYNTAX_ERROR_PARAM_TYPE
    End

    Example 'outputs error if value is missing'
      When invoke shellspec_modifier word
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End

    Example 'outputs error if next word is missing'
      When invoke shellspec_modifier word 2
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
