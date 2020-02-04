#shellcheck shell=sh

Describe "core/modifiers/word.sh"
  BeforeRun set_subject modifier_mock

  Describe "word modifier"
    Example 'example'
      The word 2 of value "foo bar baz" should equal bar
    End

    It 'gets the specified word'
      subject() { printf 'foo  bar \t baz \n qux'; }
      When run shellspec_modifier_word 4 _modifier_
      The stdout should equal qux
    End

    It 'can not the get word when subject is undefined'
      subject() { false; }
      When run shellspec_modifier_word 1 _modifier_
      The status should be failure
    End

    It 'outputs error if value is not a number'
      subject() { printf 'foo  bar \t baz \n qux'; }
      When run shellspec_modifier_word ni _modifier_
      The stderr should equal SYNTAX_ERROR_PARAM_TYPE
    End

    It 'outputs error if value is missing'
      subject() { printf 'foo  bar \t baz \n qux'; }
      When run shellspec_modifier_word
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End

    It 'outputs error if next word is missing'
      subject() { printf 'foo  bar \t baz \n qux'; }
      When run shellspec_modifier_word 2
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
