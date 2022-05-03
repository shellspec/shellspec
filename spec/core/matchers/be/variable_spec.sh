# shellcheck shell=sh disable=SC2016,SC2286,SC2287,SC2288

Describe "core/matchers/be/variable.sh"
  BeforeRun set_subject matcher_mock

  Describe 'be defined matcher'
    Before 'var1=1' 'unset var2 ||:'
    Example 'example'
      The variable var1 should be defined
      The variable var2 should not be defined
    End

    It 'matches empty string'
      subject() { %- ""; }
      When run shellspec_matcher_be_defined
      The status should be success
    End

    It 'does not match undefined'
      subject() { false; }
      When run shellspec_matcher_be_defined
      The status should be failure
    End

    It 'outputs error if parameters count is invalid'
      subject() { %- ""; }
      When run shellspec_matcher_be_defined foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End
  End

  Describe 'be undefined matcher'
    Before 'unset var1 ||:' 'var2=1'
    Example 'example'
      The variable var1 should be undefined
      The variable var2 should not be undefined
    End

    It 'does not match empty string'
      subject() { %- ""; }
      When run shellspec_matcher_be_undefined
      The status should be failure
    End

    It 'matches undefined'
      subject() { false; }
      When run shellspec_matcher_be_undefined
      The status should be success
    End

    It 'outputs error if parameters count is invalid'
      subject() { %- ""; }
      When run shellspec_matcher_be_undefined foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End
  End

  Describe 'be present matcher'
    Before 'var1="x" var2=""'
    Example 'example'
      The variable var1 should be present
      The variable var2 should not be present
    End

    It 'matches non zero length string'
      subject() { %- "x"; }
      When run shellspec_matcher_be_present
      The status should be success
    End

    It 'does not match zero length string'
      subject() { %- ""; }
      When run shellspec_matcher_be_present
      The status should be failure
    End

    It 'does not match undefind'
      subject() { false; }
      When run shellspec_matcher_be_present
      The status should be failure
    End

    It "matches with '!'"
      subject() { %- "!"; }
      When run shellspec_matcher_be_present
      The status should be success
    End

    It 'outputs error if parameters count is invalid'
      subject() { %- "x"; }
      When run shellspec_matcher_be_present foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End
  End

  Describe 'be blank matcher'
    Before 'var1="" var2="x"'
    Example 'example'
      The variable var1 should be blank
      The variable var2 should not be blank
    End

    It 'matches zero length string'
      subject() { %- ""; }
      When run shellspec_matcher_be_blank
      The status should be success
    End

    It 'matches undefind'
      subject() { false; }
      When run shellspec_matcher_be_blank
      The status should be success
    End

    It 'does not match non zero length string'
      subject() { %- "x"; }
      When run shellspec_matcher_be_blank
      The status should be failure
    End

    It "matches with '!'"
      subject() { %- "!"; }
      When run shellspec_matcher_be_blank
      The status should be failure
    End

    It 'outputs error if parameters count is invalid'
      subject() { %- ""; }
      When run shellspec_matcher_be_blank foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End
  End

  Describe 'be exported matcher'
    Before 'export var1=1' 'unset var2 ||:' 'var2=1'
    Example 'example'
      The variable var1 should be exported
      The variable var2 should not be exported
    End

    It 'matches exported variable'
      subject() { %- ""; }
      BeforeRun 'SHELLSPEC_META=variable:var' 'export var=123'
      When run shellspec_matcher_be_exported
      The status should be success
    End

    It 'does not match not exported variable'
      subject() { false; }
      BeforeRun 'SHELLSPEC_META=variable:var' 'var=123'
      When run shellspec_matcher_be_exported
      The status should be failure
    End

    It 'outputs error if subject is not variable'
      subject() { %- ""; }
      preserve() { %preserve SHELLSPEC_SW_SYNTAX_ERROR:SYNTAX_ERROR; }
      BeforeRun 'SHELLSPEC_META=text'
      AfterRun preserve

      When run shellspec_matcher_be_exported
      The stderr should equal SYNTAX_ERROR
      The variable SYNTAX_ERROR should equal 1
    End

    It 'outputs error if parameters count is invalid'
      subject() { %- ""; }
      When run shellspec_matcher_be_exported foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End
  End

  Describe 'be readonly matcher'
    Skip if "readonly malfunction" readonly_malfunction

    Example 'example'
      # shellcheck disable=SC2034
      var1=1 var2=2 var3=3
      # shellcheck disable=SC2034
      readonly var1
      unset var3
      The variable var1 should be readonly
      The variable var2 should not be readonly
      The variable var3 should not be readonly
    End

    It 'matches readonly variable'
      subject() { %- ""; }

      # shellcheck disable=SC2034
      matcher_be_readonly() {
        readonly var
        shellspec_matcher_be_readonly
      }

      BeforeRun 'SHELLSPEC_META=variable:var' 'var=123'
      When run matcher_be_readonly
      The status should be success
    End

    It 'does not match not readonly variable'
      subject() { false; }
      BeforeRun 'SHELLSPEC_META=variable:var' 'var=123'
      When run shellspec_matcher_be_readonly
      The status should be failure
    End

    It 'outputs error if subject is not variable'
      subject() { %- ""; }
      preserve() { %preserve SHELLSPEC_SW_SYNTAX_ERROR:SYNTAX_ERROR; }
      BeforeRun 'SHELLSPEC_META=text'
      AfterRun preserve

      When run shellspec_matcher_be_readonly
      The stderr should equal SYNTAX_ERROR
      The variable SYNTAX_ERROR should equal 1
    End

    It 'outputs error if parameters count is invalid'
      subject() { %- ""; }
      When run shellspec_matcher_be_readonly foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End
  End
End
