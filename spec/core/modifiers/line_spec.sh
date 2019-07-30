#shellcheck shell=sh

Describe "core/modifiers/line.sh"
  BeforeRun set_subject modifier_mock

  Describe "line modifier"
    Example 'example'
      The line 1 of value foobarbaz should equal foobarbaz
    End

    It 'gets the first line'
      subject() { %- "foo"; }
      When run shellspec_modifier_line 1 _modifier_
      The entire stdout should equal foo
    End

    It 'gets the specified line'
      subject() { %- "foo${LF}bar${LF}baz"; }
      When run shellspec_modifier_line 2 _modifier_
      The entire stdout should equal bar
    End

    It 'gets undefined when missing line'
      subject() { %- "foo${LF}"; }
      When run shellspec_modifier_line 2 _modifier_
      The status should be failure
    End

    It 'gets the specified empty line'
      subject() { %- "foo${LF}${LF}"; }
      When run shellspec_modifier_line 2 _modifier_
      The entire stdout should equal ""
    End

    It 'can not get the first line when subject is empty'
      subject() { %- ""; }
      When run shellspec_modifier_line 1 _modifier_
      The status should be failure
    End

    It 'gets the first line as "" when subject is "<LF>"'
      subject() { %- "${LF}"; }
      When run shellspec_modifier_line 1 _modifier_
      The entire stdout should equal ""
    End

    It 'can not get the first line when subject is undefined'
      subject() { false; }
      When run shellspec_modifier_line 2 _modifier_
      The status should be failure
    End

    It 'outputs error if value is not a number'
      subject() { %- "foo"; }
      When run shellspec_modifier_line ni
      The stderr should equal SYNTAX_ERROR_PARAM_TYPE
    End

    It 'outputs error if value is missing'
      subject() { %- "foo"; }
      When run shellspec_modifier_line
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End

    It 'outputs error if next word is missing'
      subject() { %- "foo"; }
      When run shellspec_modifier_line 2
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
