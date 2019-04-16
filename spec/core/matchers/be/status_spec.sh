#shellcheck shell=sh

Describe "core/matchers/be/status.sh"
  Before set_subject intercept_shellspec_matcher
  subject() { false; }

  Describe 'be success matcher'
    Example 'example'
      The value 0 should be success
      The value 1 should not be success
    End

    Context 'when subject is 0'
      subject() { %- 0; }
      It 'matches'
        When invoke shellspec_matcher be success
        The status should be success
      End
    End

    Context 'when subject is 1'
      subject() { %- 1; }
      It 'does not match'
        When invoke shellspec_matcher be success
        The status should be failure
      End
    End

    Context 'when subject is non numeric values'
      subject() { %- "a"; }
      It 'does not match'
        When invoke shellspec_matcher be success
        The status should be failure
      End
    End

    Context 'when subject is zero length string'
      subject() { %- ""; }
      It 'does not match'
        When invoke shellspec_matcher be success
        The status should be failure
      End
    End

    Context 'when subject is undefined'
      subject() { false; }
      It 'does not match'
        When invoke shellspec_matcher be success
        The status should be failure
      End
    End

    It 'outputs error if parameters count is invalid'
      When invoke shellspec_matcher be success foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be failure matcher'
    Example 'example'
      The value 1 should be failure
      The value 0 should not be failure
    End

    Context 'when subject is 1'
      subject() { %- 1; }
      It 'matches'
        When invoke shellspec_matcher be failure
        The status should be success
      End
    End

    Context 'when subject is 0'
      subject() { %- 0; }
      It 'does not match'
        When invoke shellspec_matcher be failure
        The status should be failure
      End
    End

    Context 'when subject is -1'
      subject() { %- -1; }
      It 'does not match'
        When invoke shellspec_matcher be failure
        The status should be failure
      End
    End

    Context 'when subject is 255'
      subject() { %- 255; }
      It 'matches'
        When invoke shellspec_matcher be failure
        The status should be success
      End
    End

    Context 'when subject is 256'
      subject() { %- 256; }
      It 'does not match'
        When invoke shellspec_matcher be failure
        The status should be failure
      End
    End

    Context 'when subject is non numeric values'
      subject() { %- "a"; }
      It 'does not match'
        When invoke shellspec_matcher be failure
        The status should be failure
      End
    End

    Context 'when subject is zero length string'
      subject() { %- ""; }
      It 'does not match'
        When invoke shellspec_matcher be failure
        The status should be failure
      End
    End

    Context 'when subject is undefined'
      It 'does not match'
        When invoke shellspec_matcher be failure
        The status should be failure
      End
    End

    It 'outputs error if parameters count is invalid'
      When invoke shellspec_matcher be failure foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End
End