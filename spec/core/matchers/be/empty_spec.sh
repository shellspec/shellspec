#shellcheck shell=sh disable=SC2016

% FIXTURE: "$SHELLSPEC_SPECDIR/fixture"
% EMPTYDIR: "$SHELLSPEC_TMPBASE/emptydir"

Describe "core/matchers/be/empty.sh"
  Before set_subject intercept_shellspec_matcher
  subject() { false; }

  Path empty-file="$FIXTURE/empty"
  Path not-empty-file="$FIXTURE/file"
  Path not-exists-file="$FIXTURE/not-exists"

  Describe 'be empty file matcher'
    Example 'example'
      The path empty-file should be empty file
      The path not-empty-file should not be empty file
      The path not-exists-file should not be empty file
    End

    Context 'when path is empty file'
      subject() { %- "$FIXTURE/empty"; }
      It 'matches'
        When invoke shellspec_matcher be empty file
        The status should be success
      End
    End

    Context 'when path is not empty file'
      subject() { %- "$FIXTURE/file"; }
      It 'does not match'
        When invoke shellspec_matcher be empty file
        The status should be failure
      End
    End

    Context 'when path does not exist'
      subject() { %- "$FIXTURE/not-exists"; }
      It 'does not match'
        When invoke shellspec_matcher be empty file
        The status should be failure
      End
    End

    It 'outputs error if parameters count is invalid'
      When invoke shellspec_matcher be empty file foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be empty directory matcher'
    Before 'mkdir "$EMPTYDIR"'
    After 'rmdir "$EMPTYDIR"'

    Example 'example'
      Path empty-dir="$EMPTYDIR"
      The path empty-dir should be empty directory
      The path empty-dir should be empty dir
    End

    Context 'when path is empty file'
      subject() { %- "$FIXTURE/empty"; }
      It 'does not matches'
        When invoke shellspec_matcher be empty directory
        The status should be failure
      End
    End

    Context 'when path does not exists'
      subject() { %- "$FIXTURE/not-exists"; }
      It 'does not matches'
        When invoke shellspec_matcher be empty directory
        The status should be failure
      End
    End

    Context 'when path empty directory'
      subject() { %- "$EMPTYDIR"; }
      It 'matches'
        When invoke shellspec_matcher be empty directory
        The status should be success
      End
    End

    Context 'when directory contains "file" file'
      Before 'touch "$EMPTYDIR/file"'
      After 'rm "$EMPTYDIR/file"'
      subject() { %- "$EMPTYDIR"; }
      It 'does not matches'
        When invoke shellspec_matcher be empty directory
        The status should be failure
      End
    End

    Context 'when directory contains "*" file'
      Before 'touch "$EMPTYDIR/*"'
      After 'rm "$EMPTYDIR/*"'
      subject() { %- "$EMPTYDIR"; }
      It 'does not matches'
        When invoke shellspec_matcher be empty directory
        The status should be failure
      End
    End

    Context 'when directory contains ".dot" file'
      Before 'touch "$EMPTYDIR/.dot"'
      After 'rm "$EMPTYDIR/.dot"'
      subject() { %- "$EMPTYDIR"; }
      It 'does not matches'
        When invoke shellspec_matcher be empty directory
        The status should be failure
      End
    End

    Context 'when disabled noglob'
      Before 'touch "$EMPTYDIR/file"'
      After 'rm "$EMPTYDIR/file"'
      Before 'set -o noglob'

      subject() { %- "$EMPTYDIR"; }
      It 'does not matches'
        When invoke shellspec_matcher be empty directory
        The status should be failure
      End
    End

    Context 'when enabled failglob in bash'
      Skip if 'is not bash' [ "$SHELLSPEC_SHELL_TYPE" != "bash" ]
      Before '{ shopt -s failglob ||:; } 2>/dev/null'

      subject() { %- "$EMPTYDIR"; }
      It 'matches'
        When invoke shellspec_matcher be empty directory
        The status should be success
      End
    End

    It 'outputs error if parameters count is invalid'
      When invoke shellspec_matcher be empty directory foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End
End
