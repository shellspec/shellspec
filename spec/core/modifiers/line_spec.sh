#shellcheck shell=sh

Describe "core/modifiers/line.sh"
  Before set_subject intercept_shellspec_modifier
  subject() { false; }

  Describe "line modifier"
    Example 'example'
      The line 1 of value foobarbaz should equal foobarbaz
    End

    Context 'when subject is "foo<LF>bar<LF>baz"'
      subject() { %- "foo${LF}bar${LF}baz"; }
      It 'get the second line as "bar"'
        When invoke shellspec_modifier line 2 _modifier_
        The entire stdout should equal bar
      End
    End

    Context 'when subject is "foo<LF>"'
      subject() { %- "foo${LF}"; }
      It 'can not get the second line'
        When invoke shellspec_modifier line 2 _modifier_
        The status should be failure
      End
    End

    Context 'when subject is "foo<LF><LF>"'
      subject() { %- "foo${LF}${LF}"; }
      It 'get the second line as ""'
        When invoke shellspec_modifier line 2 _modifier_
        The entire stdout should equal ""
      End
    End

    Context 'when subject is empty string'
      subject() { %- ""; }
      It 'can not get the first line'
        When invoke shellspec_modifier line 1 _modifier_
        The status should be failure
      End
    End

    Context 'when subject is "<LF>"'
      subject() { %- "${LF}"; }
      It 'get the second line as ""'
        When invoke shellspec_modifier line 1 _modifier_
        The entire stdout should equal ""
      End
    End

    Context 'when subject is undefined'
      It 'can not get the first line'
        When invoke shellspec_modifier line 2 _modifier_
        The status should be failure
      End
    End

    It 'outputs error if value is not a number'
      When invoke shellspec_modifier line ni
      The stderr should equal SYNTAX_ERROR_PARAM_TYPE
    End

    It 'outputs error if value is missing'
      When invoke shellspec_modifier line
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End

    It 'outputs error if next word is missing'
      When invoke shellspec_modifier line 2
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
