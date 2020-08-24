#shellcheck shell=sh

Describe "core/modifiers/line.sh"
  BeforeRun set_subject modifier_mock

  Describe "line modifier"
    Example 'example'
      The line 1 of value foobarbaz should equal foobarbaz
    End

    It 'gets the first line'
      subject() { printf 'foo'; }
      preserve() { %preserve SHELLSPEC_META:META; }
      AfterRun preserve

      When run shellspec_modifier_line 1 _modifier_
      The entire stdout should equal foo
      The variable META should eq 'text'
    End

    It 'gets the specified line'
      subject() { printf '\n\n\n\n\n\nfoo\nbar\nbaz'; }
      When run shellspec_modifier_line 08 _modifier_
      The entire stdout should equal bar
    End

    It 'gets undefined when missing line'
      subject() { printf 'foo\n'; }
      When run shellspec_modifier_line 2 _modifier_
      The status should be failure
    End

    It 'gets the specified empty line'
      subject() { printf 'foo\n\n'; }
      When run shellspec_modifier_line 2 _modifier_
      The entire stdout should equal ""
    End

    It 'can not get the first line when subject is empty'
      subject() { printf ''; }
      When run shellspec_modifier_line 1 _modifier_
      The status should be failure
    End

    It 'gets the first line as "" when subject is "<LF>"'
      subject() { printf '\n'; }
      When run shellspec_modifier_line 1 _modifier_
      The entire stdout should equal ""
    End

    It 'can not get the first line when subject is undefined'
      subject() { false; }
      When run shellspec_modifier_line 2 _modifier_
      The status should be failure
    End

    It 'outputs error if value is not a number'
      subject() { printf 'foo'; }
      When run shellspec_modifier_line ni
      The stderr should equal SYNTAX_ERROR_PARAM_TYPE
    End

    It 'outputs error if value is missing'
      subject() { printf 'foo'; }
      When run shellspec_modifier_line
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End

    It 'outputs error if next word is missing'
      subject() { printf 'foo'; }
      When run shellspec_modifier_line 2
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
