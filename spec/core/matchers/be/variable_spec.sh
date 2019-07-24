#shellcheck shell=sh

Describe "core/matchers/be/variable.sh"
  Before set_subject intercept_shellspec_matcher
  subject() { false; }

  Describe 'be defined matcher'
    Before 'var1=1' 'unset var2'
    Example 'example'
      The variable var1 should be defined
      The variable var2 should not be defined
    End

    Context 'when subject is empty string'
      subject() { %- ""; }
      It 'matches'
        When invoke shellspec_matcher be defined
        The status should be success
      End
    End

    Context 'when subject is undefined'
      It 'does not match'
        When invoke shellspec_matcher be defined
        The status should be failure
      End
    End

    It 'outputs error if parameters count is invalid'
      When invoke shellspec_matcher be defined foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be undefined matcher'
    Before 'unset var1' 'var2=1'
    Example 'example'
      The variable var1 should be undefined
      The variable var2 should not be undefined
    End

    Context 'when subject is empty string'
      subject() { %- ""; }
      It 'does not match'
        When invoke shellspec_matcher be undefined
        The status should be failure
      End
    End

    Context 'when subject is undefined'
      It 'matches'
        When invoke shellspec_matcher be undefined
        The status should be success
      End
    End

    It 'outputs error if parameters count is invalid'
      When invoke shellspec_matcher be undefined foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be present matcher'
    Before 'var1="x" var2=""'
    Example 'example'
      The variable var1 should be present
      The variable var2 should not be present
    End

    Context 'when subject is non zero length string'
      subject() { %- "x"; }
      It 'matches'
        When invoke shellspec_matcher be present
        The status should be success
      End
    End

    Context 'when subject is zero length string'
      subject() { %- ""; }
      It 'does not match'
        When invoke shellspec_matcher be present
        The status should be failure
      End
    End

    Context 'when subject is undefind'
      It 'does not match'
        When invoke shellspec_matcher be present
        The status should be failure
      End
    End

    It 'outputs error if parameters count is invalid'
      When invoke shellspec_matcher be present foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be blank matcher'
    Before 'var1="" var2="x"'
    Example 'example'
      The variable var1 should be blank
      The variable var2 should not be blank
    End

    Context 'when subject is zero length string'
      subject() { %- ""; }
      It 'matches'
        When invoke shellspec_matcher be blank
        The status should be success
      End
    End

    Context 'when subject is undefind'
      It 'matches'
        When invoke shellspec_matcher be blank
        The status should be success
      End
    End

    Context 'when subject is non zero length string'
      subject() { %- "x"; }
      It 'does not match'
        When invoke shellspec_matcher be blank
        The status should be failure
      End
    End

    It 'outputs error if parameters count is invalid'
      When invoke shellspec_matcher be blank foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End
End