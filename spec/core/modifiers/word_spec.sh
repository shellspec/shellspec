#shellcheck shell=sh

Describe "core/modifiers/word.sh"
  Describe "word modifier"
    Example 'example'
      The word 2 of value "foo bar baz" should equal bar
    End

    Example 'second word is bar'
      Set SHELLSPEC_SUBJECT="foo  bar $SHELLSPEC_TAB baz $SHELLSPEC_LF qux"
      When invoke modifier word 2 _modifier_
      The stdout should equal bar
    End

    Example 'third word is baz'
      Set SHELLSPEC_SUBJECT="foo  bar $SHELLSPEC_TAB baz $SHELLSPEC_LF qux"
      When invoke modifier word 3 _modifier_
      The stdout should equal baz
    End

    Example 'fourth word is qux'
      Set SHELLSPEC_SUBJECT="foo  bar $SHELLSPEC_TAB baz $SHELLSPEC_LF qux"
      When invoke modifier word 4 _modifier_
      The stdout should equal qux
    End

    Example 'can not get word of undefined subject'
      Unset SHELLSPEC_SUBJECT
      When invoke modifier word 1 _modifier_
      The exit status should be failure
    End

    Example 'output error if value is not a number'
      Set SHELLSPEC_SUBJECT="foo  bar $SHELLSPEC_TAB baz $SHELLSPEC_LF qux"
      When invoke modifier word ni _modifier_
      The stderr should equal SYNTAX_ERROR_PARAM_TYPE
    End

    Example 'output error if value is missing'
      Set SHELLSPEC_SUBJECT="foo  bar $SHELLSPEC_TAB baz $SHELLSPEC_LF qux"
      When invoke modifier word
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End

    Example 'output error if next word is missing'
      Set SHELLSPEC_SUBJECT="foo  bar $SHELLSPEC_TAB baz $SHELLSPEC_LF qux"
      When invoke modifier word 2
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
