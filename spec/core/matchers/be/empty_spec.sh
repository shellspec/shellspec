#shellcheck shell=sh

% FIXTURE: "$SHELLSPEC_SPECDIR/fixture"

Describe "core/matchers/be/empty.sh"
  Before set_subject intercept_shellspec_matcher
  subject() { false; }

   Describe 'be empty matcher'
    Example 'example'
      Path empty-file="$FIXTURE/empty"
      Path not-empty-file="$FIXTURE/file"
      Path not-exists-file="$FIXTURE/not-exists"
      The path empty-file should be empty
      The path not-empty-file should not be empty
      The path not-exists-file should not be empty
    End

    Context 'when path is empty'
      subject() { %- "$FIXTURE/empty"; }
      It 'matches'
        When invoke shellspec_matcher be empty
        The status should be success
      End
    End

    Context 'when path is not empty'
      subject() { %- "$FIXTURE/file"; }
      It 'does not match'
        When invoke shellspec_matcher be empty
        The status should be failure
      End
    End

    Context 'when path does not exist'
      subject() { %- "$FIXTURE/not-exists"; }
      It 'does not match'
        When invoke shellspec_matcher be empty
        The status should be failure
      End
    End

    It 'outputs error if parameters count is invalid'
      When invoke shellspec_matcher be empty foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End
End
