#shellcheck shell=sh

Describe "core/matchers/be/stat.sh"
  setup() { fixture="$SHELLSPEC_SPECDIR/fixture"; }
  Before setup

  not_exist() { setup; [ ! -e "$fixture/$1" ]; }
  check_root() { [ "$(id -u)" = 0 ]; }

  Describe 'be exist matcher'
    Example 'example'
      Path exist-file="$fixture/exist"
      The path exist-file should be exist
    End

    Example 'succeed if path exists'
      Set SHELLSPEC_SUBJECT="$fixture/exist"
      When invoke matcher be exist
      The status should be success
    End

    Example 'fail if path does not exist'
      Set SHELLSPEC_SUBJECT="$fixture/exist.not-exists"
      When invoke matcher be exist
      The status should be failure
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

    Example 'succeed if path is regular file'
      Set SHELLSPEC_SUBJECT="$fixture/file"
      When invoke matcher be file
      The status should be success
    End

    Example 'fail if path is not regular file'
      Set SHELLSPEC_SUBJECT="$fixture/dir"
      When invoke matcher be file
      The status should be failure
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

    Example 'succeed if path is directory'
      Set SHELLSPEC_SUBJECT="$fixture/dir"
      When invoke matcher be directory
      The status should be success
    End

    Example 'fail if path is not directory'
      Set SHELLSPEC_SUBJECT="$fixture/file"
      When invoke matcher be directory
      The status should be failure
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

    Example 'succeed if path is empty'
      Set SHELLSPEC_SUBJECT="$fixture/empty"
      When invoke matcher be empty
      The status should be success
    End

    Example 'fail if path is not empty'
      Set SHELLSPEC_SUBJECT="$fixture/file"
      When invoke matcher be empty
      The status should be failure
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

    Example 'succeed if path is symlink'
      Set SHELLSPEC_SUBJECT="$fixture/stat/symlink"
      When invoke matcher be symlink
      The status should be success
    End

    Example 'fail if path is not symlink'
      Set SHELLSPEC_SUBJECT="$fixture/file"
      When invoke matcher be symlink
      The status should be failure
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

    Example 'succeed if path is pipe'
      Set SHELLSPEC_SUBJECT="$fixture/stat/pipe"
      When invoke matcher be pipe
      The status should be success
    End

    Example 'fail if path is not pipe'
      Set SHELLSPEC_SUBJECT="$fixture/file"
      When invoke matcher be pipe
      The status should be failure
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

    Example 'succeed if path is socket'
      Set SHELLSPEC_SUBJECT="$fixture/stat/socket"
      When invoke matcher be socket
      The status should be success
    End

    Example 'fail if path is not socket'
      Set SHELLSPEC_SUBJECT="$fixture/file"
      When invoke matcher be socket
      The status should be failure
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

    Example 'succeed if path is readable'
      Set SHELLSPEC_SUBJECT="$fixture/stat/readable"
      When invoke matcher be readable
      The status should be success
    End

    Example 'fail if path is not readable'
      Skip if "I am root" check_root
      Set SHELLSPEC_SUBJECT="$fixture/stat/no-permission"
      When invoke matcher be readable
      The status should be failure
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

    Example 'succeed if path is writable'
      Set SHELLSPEC_SUBJECT="$fixture/stat/writable"
      When invoke matcher be writable
      The status should be success
    End

    Example 'fail if path is not writable'
      Skip if "I am root" check_root
      Set SHELLSPEC_SUBJECT="$fixture/stat/no-permission"
      When invoke matcher be writable
      The status should be failure
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

    Example 'succeed if path is executable'
      Set SHELLSPEC_SUBJECT="$fixture/stat/executable"
      When invoke matcher be executable
      The status should be success
    End

    Example 'fail if path is not executable'
      Set SHELLSPEC_SUBJECT="$fixture/stat/no-permission"
      When invoke matcher be executable
      The status should be failure
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

    Example 'succeed if path is block device'
      Set SHELLSPEC_SUBJECT="$fixture/stat/block-device"
      When invoke matcher be block device
      The status should be success
    End

    Example 'fail if path is not block device'
      Set SHELLSPEC_SUBJECT="$fixture/file"
      When invoke matcher be block device
      The status should be failure
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

    Example 'succeed if path is charactor device'
      Set SHELLSPEC_SUBJECT="$fixture/stat/charactor-device"
      When invoke matcher be charactor device
      The status should be success
    End

    Example 'fail if path is not charactor device'
      Set SHELLSPEC_SUBJECT="$fixture/file"
      When invoke matcher be charactor device
      The status should be failure
    End

    Example 'output error if parameters count is invalid'
      When invoke matcher be charactor device foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End
End
