#shellcheck shell=sh

Describe "core/modifiers/word.sh"
  Before set_subject intercept_shellspec_modifier
  subject() { false; }

  Describe "word modifier"
    Example 'example'
      The word 2 of value "foo bar baz" should equal bar
    End

    Context 'when subject is "foo  bar <TAB> baz <LF> qux"'
      subject() { %- "foo  bar $TAB baz $LF qux"; }

      It 'get the second word as "bar"'
        When invoke shellspec_modifier word 2 _modifier_
        The stdout should equal bar
      End

      It 'get the third word as "baz"'
        When invoke shellspec_modifier word 3 _modifier_
        The stdout should equal baz
      End

      It 'get the third word as "qux"'
        When invoke shellspec_modifier word 4 _modifier_
        The stdout should equal qux
      End
    End

    Context 'when subject is undefined'
      It 'can not the get word'
        When invoke shellspec_modifier word 1 _modifier_
        The status should be failure
      End
    End

    It 'outputs error if value is not a number'
      When invoke shellspec_modifier word ni _modifier_
      The stderr should equal SYNTAX_ERROR_PARAM_TYPE
    End

    It 'outputs error if value is missing'
      When invoke shellspec_modifier word
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End

    It 'outputs error if next word is missing'
      When invoke shellspec_modifier word 2
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
