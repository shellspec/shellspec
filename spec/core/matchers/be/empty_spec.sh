#shellcheck shell=sh disable=SC2016

% FIXTURE: "$SHELLSPEC_SPECDIR/fixture"
% EMPTYDIR: "$SHELLSPEC_TMPBASE/emptydir"

Describe "core/matchers/be/empty.sh"
  BeforeRun set_subject matcher_mock

  Path empty-file="$FIXTURE/empty"
  Path not-empty-file="$FIXTURE/file"
  Path not-exists-file="$FIXTURE/not-exists"

  Describe 'be empty file matcher'
    Example 'example'
      The path empty-file should be empty file
      The path not-empty-file should not be empty file
      The path not-exists-file should not be empty file
    End

    It 'matches empty file'
      subject() { %- "$FIXTURE/empty"; }
      When run shellspec_matcher_be_empty_file
      The status should be success
    End

    It 'does not match not empty file'
      subject() { %- "$FIXTURE/file"; }
      When run shellspec_matcher_be_empty_file
      The status should be failure
    End

    It 'does not match not exist file'
      subject() { %- "$FIXTURE/not-exists"; }
      When run shellspec_matcher_be_empty_file
      The status should be failure
    End

    It 'outputs error if parameters count is invalid'
      subject() { %- "$FIXTURE/empty"; }
      When run shellspec_matcher_be_empty_file foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
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

    It 'does not matches empty file'
      subject() { %- "$FIXTURE/empty"; }
      When run shellspec_matcher_be_empty_directory
      The status should be failure
    End

    It 'does not matches not exists directory'
      subject() { %- "$FIXTURE/not-exists"; }
      When run shellspec_matcher_be_empty_directory
      The status should be failure
    End

    It 'matches empty directory'
      subject() { %- "$EMPTYDIR"; }
      When run shellspec_matcher_be_empty_directory
      The status should be success
    End

    Context 'when directory contains "file" file'
      Before 'touch "$EMPTYDIR/file"'
      After 'rm "$EMPTYDIR/file"'

      It 'does not matches'
        subject() { %- "$EMPTYDIR"; }
        When run shellspec_matcher_be_empty_directory
        The status should be failure
      End
    End

    Context 'when directory contains "*" file'
      Before 'touch "$EMPTYDIR/*"'
      After 'rm "$EMPTYDIR/*"'

      It 'does not matches'
        subject() { %- "$EMPTYDIR"; }
        When run shellspec_matcher_be_empty_directory
        The status should be failure
      End
    End

    Context 'when directory contains ".dot" file'
      Before 'touch "$EMPTYDIR/.dot"'
      After 'rm "$EMPTYDIR/.dot"'

      It 'does not matches contains ".dot" file'
        subject() { %- "$EMPTYDIR"; }
        When run shellspec_matcher_be_empty_directory
        The status should be failure
      End
    End

    Context 'when disabled noglob'
      Before 'touch "$EMPTYDIR/file"'
      After 'rm "$EMPTYDIR/file"'
      Before 'set -o noglob'
      subject() { %- "$EMPTYDIR"; }
      It 'does not matches'
        When run shellspec_matcher_be_empty_directory
        The status should be failure
      End
    End

    Context 'when enabled failglob in bash'
      Skip if 'shell is not bash' [ "$SHELLSPEC_SHELL_TYPE" != "bash" ]
      Before '{ shopt -s failglob ||:; } 2>/dev/null'

      It 'matches'
        subject() { %- "$EMPTYDIR"; }
        When run shellspec_matcher_be_empty_directory
        The status should be success
      End
    End

    It 'outputs error if parameters count is invalid'
      subject() { %- "$EMPTYDIR"; }
      When run shellspec_matcher_be_empty_directory foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End
  End
End
