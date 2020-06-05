#shellcheck shell=sh

% FIXTURE: "$SHELLSPEC_SPECDIR/fixture"

Describe "core/matchers/be/stat.sh"
  BeforeRun set_subject matcher_mock

  not_exist() { [ ! -e "$FIXTURE/$1" ]; }
  check_root() { [ "$(id -u)" = 0 ]; }

  Describe 'be exist matcher'
    Example 'example'
      Path exist-file="$FIXTURE/exist"
      The path exist-file should be exist
    End

    It 'matches when path exists'
      subject() { %- "$FIXTURE/exist"; }
      When run shellspec_matcher_be_exist
      The status should be success
    End

    It 'does not match when path does not exist'
      subject() { %- "$FIXTURE/exist.not-exists"; }
      When run shellspec_matcher_be_exist
      The status should be failure
    End

    It 'outputs error if parameters count is invalid'
      subject() { %- "$FIXTURE/exist"; }
      When run shellspec_matcher_be_exist foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End
  End

  Describe 'be file matcher'
    Example 'example'
      Path regular-file="$FIXTURE/file"
      The path regular-file should be file
    End

    It 'matches when path is regular file'
      subject() { %- "$FIXTURE/file"; }
      When run shellspec_matcher_be_file
      The status should be success
    End

    It 'does not match when path is not regular file'
      subject() { %- "$FIXTURE/dir"; }
      When run shellspec_matcher_be_file
      The status should be failure
    End

    It 'outputs error if parameters count is invalid'
      subject() { %- "$FIXTURE/file"; }
      When run shellspec_matcher_be_file foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End
  End

  Describe 'be directory matcher'
    Example 'example'
      Path directory="$FIXTURE/dir"
      The path directory should be directory
    End

    It 'matches when path is directory'
      subject() { %- "$FIXTURE/dir"; }
      When run shellspec_matcher_be_directory
      The status should be success
    End

    It 'does not match when path is not directory'
      subject() { %- "$FIXTURE/file"; }
      When run shellspec_matcher_be_directory
      The status should be failure
    End

    It 'outputs error if parameters count is invalid'
      subject() { %- "$FIXTURE/dir"; }
      When run shellspec_matcher_be_directory foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End
  End

  Describe 'be symlink matcher'
    Skip if "not exist symlink file" not_exist "stat/symlink"

    Example 'example'
      Path symlink="$FIXTURE/stat/symlink"
      The path symlink should be symlink
    End

    It 'matches when path is symlink'
      subject() { %- "$FIXTURE/stat/symlink"; }
      When run shellspec_matcher_be_symlink
      The status should be success
    End

    It 'does not match when path is not symlink'
      subject() { %- "$FIXTURE/file"; }
      When run shellspec_matcher_be_symlink
      The status should be failure
    End

    It 'outputs error if parameters count is invalid'
      subject() { %- "$FIXTURE/stat/symlink"; }
      When run shellspec_matcher_be_symlink foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End
  End

  Describe 'be pipe matcher'
    Skip if "not exist pipe file" not_exist "stat/pipe"
    Skip if "busybox-w32 not supported" busybox_w32

    Example 'example'
      Path pipe="$FIXTURE/stat/pipe"
      The path pipe should be pipe
    End

    It 'matches when path is pipe'
      subject() { %- "$FIXTURE/stat/pipe"; }
      When run shellspec_matcher_be_pipe
      The status should be success
    End

    It 'does not match when path is not pipe'
      subject() { %- "$FIXTURE/file"; }
      When run shellspec_matcher_be_pipe
      The status should be failure
    End

    It 'outputs error if parameters count is invalid'
      subject() { %- "$FIXTURE/stat/pipe"; }
      When run shellspec_matcher_be_pipe foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End
  End

  Describe 'be socket matcher'
    Skip if "not exist socket file" not_exist "stat/socket"

    Example 'example'
      Path socket="$FIXTURE/stat/socket"
      The path socket should be socket
    End

    It 'matches when path is socket'
      subject() { %- "$FIXTURE/stat/socket"; }
      When run shellspec_matcher_be_socket
      The status should be success
    End

    It 'does not match when path is not socket'
      subject() { %- "$FIXTURE/file"; }
      When run shellspec_matcher_be_socket
      The status should be failure
    End

    It 'outputs error if parameters count is invalid'
      subject() { %- "$FIXTURE/stat/socket"; }
      When run shellspec_matcher_be_socket foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End
  End

  Describe 'be readable matcher'
    Skip if "not exist readable file" not_exist "stat/readable"

    Example 'example'
      Path readable="$FIXTURE/stat/readable"
      The path readable should be readable
    End

    It 'matches when path is readable'
      subject() { %- "$FIXTURE/stat/readable"; }
      When run shellspec_matcher_be_readable
      The status should be success
    End

    It 'does not match when path is not readable'
      Skip if "I am root" check_root
      Skip if "busybox-w32 always readable" busybox_w32
      subject() { %- "$FIXTURE/stat/no-permission"; }
      When run shellspec_matcher_be_readable
      The status should be failure
    End

    It 'outputs error if parameters count is invalid'
      subject() { %- "$FIXTURE/stat/readable"; }
      When run shellspec_matcher_be_readable foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End
  End

  Describe 'be writable matcher'
    Skip if "not exist writable file" not_exist "stat/writable"

    Example 'example'
      Path readable="$FIXTURE/stat/writable"
      The path readable should be writable
    End

    It 'matches when path is writable'
      subject() { %- "$FIXTURE/stat/writable"; }
      When run shellspec_matcher_be_writable
      The status should be success
    End

    It 'does not match when path is not writable'
      Skip if "I am root" check_root
      subject() { %- "$FIXTURE/stat/no-permission"; }
      When run shellspec_matcher_be_writable
      The status should be failure
    End

    It 'outputs error if parameters count is invalid'
      subject() { %- "$FIXTURE/stat/writable"; }
      When run shellspec_matcher_be_writable foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End
  End

  Describe 'be executable matcher'
    Skip if "not exist executable file" not_exist "stat/executable"

    Example 'example'
      Path executable="$FIXTURE/stat/executable"
      The path executable should be executable
    End

    It 'matches when path is executable'
      subject() { %- "$FIXTURE/stat/executable"; }
      When run shellspec_matcher_be_executable
      The status should be success
    End

    It 'does not match when path is not executable'
      subject() { %- "$FIXTURE/stat/no-permission"; }
      When run shellspec_matcher_be_executable
      The status should be failure
    End

    It 'outputs error if parameters count is invalid'
      subject() { %- "$FIXTURE/stat/executable"; }
      When run shellspec_matcher_be_executable foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End
  End

  Describe 'be block device matcher'
    Skip if "not exist block-device file" not_exist "stat/block-device"
    Skip if "busybox-w32 not supported" busybox_w32

    Example 'example'
      Path block-device="$FIXTURE/stat/block-device"
      The path block-device should be block device
    End

    It 'matches when path is block device'
      subject() { %- "$FIXTURE/stat/block-device"; }
      When run shellspec_matcher_be_block_device
      The status should be success
    End

    It 'does not match when path is not block device'
      subject() { %- "$FIXTURE/file"; }
      When run shellspec_matcher_be_block_device
      The status should be failure
    End

    It 'outputs error if parameters count is invalid'
      subject() { %- "$FIXTURE/stat/block-device"; }
      When run shellspec_matcher_be_block_device foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End
  End

  Describe 'be character device matcher'
    Skip if "not exist character-device file" not_exist "stat/character-device"
    Skip if "busybox-w32 not supported" busybox_w32

    Example 'example'
      Path character-device="$FIXTURE/stat/character-device"
      The path character-device should be character device
    End

    It 'matches when path is character device'
      subject() { %- "$FIXTURE/stat/character-device"; }
      When run shellspec_matcher_be_character_device
      The status should be success
    End

    It 'does not match when path is not character device'
      subject() { %- "$FIXTURE/file"; }
      When run shellspec_matcher_be_character_device
      The status should be failure
    End

    It 'outputs error if parameters count is invalid'
      subject() { %- "$FIXTURE/stat/character-device"; }
      When run shellspec_matcher_be_character_device foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End
  End
End
