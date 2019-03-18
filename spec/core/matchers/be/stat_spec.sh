#shellcheck shell=sh

Describe "core/matchers/be/stat.sh"
  Before setup set_subject
  setup() { fixture="$SHELLSPEC_SPECDIR/fixture"; }
  subject() { false; }

  not_exist() { setup; [ ! -e "$fixture/$1" ]; }
  check_root() { [ "$(id -u)" = 0 ]; }

  Describe 'be exist matcher'
    Example 'example'
      Path exist-file="$fixture/exist"
      The path exist-file should be exist
    End

    Context 'when path exists'
      subject() { shellspec_puts "$fixture/exist"; }
      Example 'it should be success'
        When invoke matcher be exist
        The status should be success
      End
    End

    Context 'when path does not exist'
      subject() { shellspec_puts "$fixture/exist.not-exists"; }
      Example 'it should be failure'
        When invoke matcher be exist
        The status should be failure
      End
    End

    Example 'output error if parameters count is invalid'
      When invoke matcher be exist foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be file matcher'
    Example 'example'
      Path regular-file="$fixture/file"
      The path regular-file should be file
    End

    Context 'when path is regular file'
      subject() { shellspec_puts "$fixture/file"; }
      Example 'it should be success'
        When invoke matcher be file
        The status should be success
      End
    End

    Context 'when path is not regular file'
      subject() { shellspec_puts "$fixture/dir"; }
      Example 'it should be failure'
        When invoke matcher be file
        The status should be failure
      End
    End

    Example 'output error if parameters count is invalid'
      When invoke matcher be file foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be directory matcher'
    Example 'example'
      Path directory="$fixture/dir"
      The path directory should be directory
    End

    Context 'when path is directory'
      subject() { shellspec_puts "$fixture/dir"; }
      Example 'it should be success'
        When invoke matcher be directory
        The status should be success
      End
    End

    Context 'when path is not directory'
      subject() { shellspec_puts "$fixture/file"; }
      Example 'it should be failure'
        When invoke matcher be directory
        The status should be failure
      End
    End

    Example 'output error if parameters count is invalid'
      When invoke matcher be directory foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be empty matcher'
    Example 'example'
      Path empty-file="$fixture/empty"
      The path empty-file should be empty
    End

    Context 'when path is empty'
      subject() { shellspec_puts "$fixture/empty"; }
      Example 'it should be success'
        When invoke matcher be empty
        The status should be success
      End
    End

    Context 'when path is not empty'
      subject() { shellspec_puts "$fixture/file"; }
      Example 'it should be failure'
        When invoke matcher be empty
        The status should be failure
      End
    End

    Example 'output error if parameters count is invalid'
      When invoke matcher be empty foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be symlink matcher'
    Skip if "not exist symlink file" not_exist "stat/symlink"

    Example 'example'
      Path symlink="$fixture/stat/symlink"
      The path symlink should be symlink
    End

    Context 'when path is symlink'
      subject() { shellspec_puts "$fixture/stat/symlink"; }
      Example 'it should be success'
        When invoke matcher be symlink
        The status should be success
      End
    End

    Context 'when path is not symlink'
      subject() { shellspec_puts "$fixture/file"; }
      Example 'it should be failure'
        When invoke matcher be symlink
        The status should be failure
      End
    End

    Example 'output error if parameters count is invalid'
      When invoke matcher be symlink foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be pipe matcher'
    Skip if "not exist pipe file" not_exist "stat/pipe"

    Example 'example'
      Path pipe="$fixture/stat/pipe"
      The path pipe should be pipe
    End

    Context 'when path is pipe'
      subject() { shellspec_puts "$fixture/stat/pipe"; }
      Example 'it should be success'
        When invoke matcher be pipe
        The status should be success
      End
    End

    Context 'when path is not pipe'
      subject() { shellspec_puts "$fixture/file"; }
      Example 'it should be failure'
        When invoke matcher be pipe
        The status should be failure
      End
    End

    Example 'output error if parameters count is invalid'
      When invoke matcher be pipe foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be socket matcher'
    Skip if "not exist socket file" not_exist "stat/socket"

    Example 'example'
      Path socket="$fixture/stat/socket"
      The path socket should be socket
    End

    Context 'when path is socket'
      subject() { shellspec_puts "$fixture/stat/socket"; }
      Example 'it should be success'
        When invoke matcher be socket
        The status should be success
      End
    End

    Context 'when path is not socket'
      subject() { shellspec_puts "$fixture/file"; }
      Example 'it should be failure'
        When invoke matcher be socket
        The status should be failure
      End
    End

    Example 'output error if parameters count is invalid'
      When invoke matcher be socket foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be readable matcher'
    Skip if "not exist readable file" not_exist "stat/readable"

    Example 'example'
      Path readable="$fixture/stat/readable"
      The path readable should be readable
    End

    Context 'when path is readable'
      subject() { shellspec_puts "$fixture/stat/readable"; }
      Example 'it should be success'
        When invoke matcher be readable
        The status should be success
      End
    End

    Context 'when path is not readable'
      subject() { shellspec_puts "$fixture/stat/no-permission"; }
      Skip if "I am root" check_root
      Example 'it should be failure'
        When invoke matcher be readable
        The status should be failure
      End
    End

    Example 'output error if parameters count is invalid'
      When invoke matcher be readable foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be writable matcher'
    Skip if "not exist writable file" not_exist "stat/writable"

    Example 'example'
      Path readable="$fixture/stat/writable"
      The path readable should be writable
    End

    Context 'when path is writable'
      subject() { shellspec_puts "$fixture/stat/writable"; }
      Example 'it should be success'
        When invoke matcher be writable
        The status should be success
      End
    End

    Context 'when path is not writable'
      subject() { shellspec_puts "$fixture/stat/no-permission"; }
      Skip if "I am root" check_root
      Example 'it should be failure'
        When invoke matcher be writable
        The status should be failure
      End
    End

    Example 'output error if parameters count is invalid'
      When invoke matcher be writable foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be executable matcher'
    Skip if "not exist executable file" not_exist "stat/executable"

    Example 'example'
      Path executable="$fixture/stat/executable"
      The path executable should be executable
    End

    Context 'when path is executable'
      subject() { shellspec_puts "$fixture/stat/executable"; }
      Example 'it should be success'
        When invoke matcher be executable
        The status should be success
      End
    End

    Context 'when path is not executable'
      subject() { shellspec_puts "$fixture/stat/no-permission"; }
      Example 'it should be failure'
        When invoke matcher be executable
        The status should be failure
      End
    End

    Example 'output error if parameters count is invalid'
      When invoke matcher be executable foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be block device matcher'
    Skip if "not exist block-device file" not_exist "stat/block-device"

    Example 'example'
      Path block-device="$fixture/stat/block-device"
      The path block-device should be block device
    End

    Context 'when path is block device'
      subject() { shellspec_puts "$fixture/stat/block-device"; }
      Example 'it should be success'
        When invoke matcher be block device
        The status should be success
      End
    End

    Context 'when path is not block device'
      subject() { shellspec_puts "$fixture/file"; }
      Example 'it should be failure'
        When invoke matcher be block device
        The status should be failure
      End
    End

    Example 'output error if parameters count is invalid'
      When invoke matcher be block device foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be charactor device matcher'
    Skip if "not exist charactor-device file" not_exist "stat/charactor-device"

    Example 'example'
      Path charactor-device="$fixture/stat/charactor-device"
      The path charactor-device should be charactor device
    End

    Context 'when path is charactor device'
      subject() { shellspec_puts "$fixture/stat/charactor-device"; }
      Example 'it should be success'
        When invoke matcher be charactor device
        The status should be success
      End
    End

    Context 'when path is not charactor device'
      subject() { shellspec_puts "$fixture/file"; }
      Example 'it should be failure'
        When invoke matcher be charactor device
        The status should be failure
      End
    End

    Example 'output error if parameters count is invalid'
      When invoke matcher be charactor device foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End
End
