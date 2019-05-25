#shellcheck shell=sh

% FIXTURE: "$SHELLSPEC_SPECDIR/fixture"

Describe "core/matchers/be/stat.sh"
  Before set_subject intercept_shellspec_matcher
  subject() { false; }

  not_exist() { [ ! -e "$FIXTURE/$1" ]; }
  check_root() { [ "$(id -u)" = 0 ]; }

  Describe 'be exist matcher'
    Example 'example'
      Path exist-file="$FIXTURE/exist"
      The path exist-file should be exist
    End

    Context 'when path exists'
      subject() { %- "$FIXTURE/exist"; }
      It 'matches'
        When invoke shellspec_matcher be exist
        The status should be success
      End
    End

    Context 'when path does not exist'
      subject() { %- "$FIXTURE/exist.not-exists"; }
      It 'does not match'
        When invoke shellspec_matcher be exist
        The status should be failure
      End
    End

    It 'outputs error if parameters count is invalid'
      When invoke shellspec_matcher be exist foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be file matcher'
    Example 'example'
      Path regular-file="$FIXTURE/file"
      The path regular-file should be file
    End

    Context 'when path is regular file'
      subject() { %- "$FIXTURE/file"; }
      It 'matches'
        When invoke shellspec_matcher be file
        The status should be success
      End
    End

    Context 'when path is not regular file'
      subject() { %- "$FIXTURE/dir"; }
      It 'does not match'
        When invoke shellspec_matcher be file
        The status should be failure
      End
    End

    It 'outputs error if parameters count is invalid'
      When invoke shellspec_matcher be file foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be directory matcher'
    Example 'example'
      Path directory="$FIXTURE/dir"
      The path directory should be directory
    End

    Context 'when path is directory'
      subject() { %- "$FIXTURE/dir"; }
      It 'matches'
        When invoke shellspec_matcher be directory
        The status should be success
      End
    End

    Context 'when path is not directory'
      subject() { %- "$FIXTURE/file"; }
      It 'does not match'
        When invoke shellspec_matcher be directory
        The status should be failure
      End
    End

    It 'outputs error if parameters count is invalid'
      When invoke shellspec_matcher be directory foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be symlink matcher'
    Skip if "not exist symlink file" not_exist "stat/symlink"

    Example 'example'
      Path symlink="$FIXTURE/stat/symlink"
      The path symlink should be symlink
    End

    Context 'when path is symlink'
      subject() { %- "$FIXTURE/stat/symlink"; }
      It 'matches'
        When invoke shellspec_matcher be symlink
        The status should be success
      End
    End

    Context 'when path is not symlink'
      subject() { %- "$FIXTURE/file"; }
      It 'does not match'
        When invoke shellspec_matcher be symlink
        The status should be failure
      End
    End

    It 'outputs error if parameters count is invalid'
      When invoke shellspec_matcher be symlink foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be pipe matcher'
    Skip if "not exist pipe file" not_exist "stat/pipe"

    Example 'example'
      Path pipe="$FIXTURE/stat/pipe"
      The path pipe should be pipe
    End

    Context 'when path is pipe'
      subject() { %- "$FIXTURE/stat/pipe"; }
      It 'matches'
        When invoke shellspec_matcher be pipe
        The status should be success
      End
    End

    Context 'when path is not pipe'
      subject() { %- "$FIXTURE/file"; }
      It 'does not match'
        When invoke shellspec_matcher be pipe
        The status should be failure
      End
    End

    It 'outputs error if parameters count is invalid'
      When invoke shellspec_matcher be pipe foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be socket matcher'
    Skip if "not exist socket file" not_exist "stat/socket"

    Example 'example'
      Path socket="$FIXTURE/stat/socket"
      The path socket should be socket
    End

    Context 'when path is socket'
      subject() { %- "$FIXTURE/stat/socket"; }
      It 'matches'
        When invoke shellspec_matcher be socket
        The status should be success
      End
    End

    Context 'when path is not socket'
      subject() { %- "$FIXTURE/file"; }
      It 'does not match'
        When invoke shellspec_matcher be socket
        The status should be failure
      End
    End

    It 'outputs error if parameters count is invalid'
      When invoke shellspec_matcher be socket foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be readable matcher'
    Skip if "not exist readable file" not_exist "stat/readable"

    Example 'example'
      Path readable="$FIXTURE/stat/readable"
      The path readable should be readable
    End

    Context 'when path is readable'
      subject() { %- "$FIXTURE/stat/readable"; }
      It 'matches'
        When invoke shellspec_matcher be readable
        The status should be success
      End
    End

    Context 'when path is not readable'
      subject() { %- "$FIXTURE/stat/no-permission"; }
      Skip if "I am root" check_root
      It 'does not match'
        When invoke shellspec_matcher be readable
        The status should be failure
      End
    End

    It 'outputs error if parameters count is invalid'
      When invoke shellspec_matcher be readable foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be writable matcher'
    Skip if "not exist writable file" not_exist "stat/writable"

    Example 'example'
      Path readable="$FIXTURE/stat/writable"
      The path readable should be writable
    End

    Context 'when path is writable'
      subject() { %- "$FIXTURE/stat/writable"; }
      It 'matches'
        When invoke shellspec_matcher be writable
        The status should be success
      End
    End

    Context 'when path is not writable'
      subject() { %- "$FIXTURE/stat/no-permission"; }
      Skip if "I am root" check_root
      It 'does not match'
        When invoke shellspec_matcher be writable
        The status should be failure
      End
    End

    It 'outputs error if parameters count is invalid'
      When invoke shellspec_matcher be writable foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be executable matcher'
    Skip if "not exist executable file" not_exist "stat/executable"

    Example 'example'
      Path executable="$FIXTURE/stat/executable"
      The path executable should be executable
    End

    Context 'when path is executable'
      subject() { %- "$FIXTURE/stat/executable"; }
      It 'matches'
        When invoke shellspec_matcher be executable
        The status should be success
      End
    End

    Context 'when path is not executable'
      subject() { %- "$FIXTURE/stat/no-permission"; }
      It 'does not match'
        When invoke shellspec_matcher be executable
        The status should be failure
      End
    End

    It 'outputs error if parameters count is invalid'
      When invoke shellspec_matcher be executable foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be block device matcher'
    Skip if "not exist block-device file" not_exist "stat/block-device"

    Example 'example'
      Path block-device="$FIXTURE/stat/block-device"
      The path block-device should be block device
    End

    Context 'when path is block device'
      subject() { %- "$FIXTURE/stat/block-device"; }
      It 'matches'
        When invoke shellspec_matcher be block device
        The status should be success
      End
    End

    Context 'when path is not block device'
      subject() { %- "$FIXTURE/file"; }
      It 'does not match'
        When invoke shellspec_matcher be block device
        The status should be failure
      End
    End

    It 'outputs error if parameters count is invalid'
      When invoke shellspec_matcher be block device foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be charactor device matcher'
    Skip if "not exist charactor-device file" not_exist "stat/charactor-device"

    Example 'example'
      Path charactor-device="$FIXTURE/stat/charactor-device"
      The path charactor-device should be charactor device
    End

    Context 'when path is charactor device'
      subject() { %- "$FIXTURE/stat/charactor-device"; }
      It 'matches'
        When invoke shellspec_matcher be charactor device
        The status should be success
      End
    End

    Context 'when path is not charactor device'
      subject() { %- "$FIXTURE/file"; }
      It 'does not match'
        When invoke shellspec_matcher be charactor device
        The status should be failure
      End
    End

    It 'outputs error if parameters count is invalid'
      When invoke shellspec_matcher be charactor device foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End
End
