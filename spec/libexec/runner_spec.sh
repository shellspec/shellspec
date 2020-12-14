#shellcheck shell=sh disable=SC2004

% FIXTURE: "$SHELLSPEC_HELPERDIR/fixture"

Describe "libexec/runner.sh"
  Include "$SHELLSPEC_LIB/libexec/runner.sh"

  change_permission() {
    @chmod "$1" "$2"
    perm=$(@ls -dl "$2")
    echo "${perm%"${perm#??????????}"}"
  }

  check_change_permission() {
    file="$SHELLSPEC_TMPBASE/check_change_permission"
    : > "$file"
    perm1=$(change_permission 644 "$file")
    perm2=$(change_permission 666 "$file")
    [ "$perm1 : $perm2" != "-rw-r--r-- : -rw-rw-rw-" ]
  }

  Describe "mktempdir()"
    Skip if 'can not change permission' check_change_permission
    mkdir() { @mkdir "$@"; }
    rm() { @rm "$@"; }

    prepare() { dir="$SHELLSPEC_TMPBASE/mktempdir_test"; }
    entry() { @ls -dl "$dir"; }
    cleanup() { rmtempdir "$dir"; }
    Before prepare
    After cleanup

    It "makes tempdir"
      When call mktempdir "$dir"
      The status should be success
      The result of 'entry()' should start with 'drwx------'
    End

    It "aborts when the created directory is not empty"
      is_empty_directory() { false; }
      When run mktempdir "$dir"
      The status should be failure
      The stderr should be present
    End
  End

  Describe "rmtempdir()"
    Before prepare
    prepare() {
      dir="$SHELLSPEC_TMPBASE/rmtempdir_test"
      mktempdir "$dir"
      [ -d "$dir" ] && [ -w "$dir" ]
    }
    mkdir() { @mkdir "$@"; }
    rm() { @rm "$@"; }

    It "deletes tempdir"
      Path tempdir="$dir"
      When call rmtempdir "$dir"
      The status should be success
      The path tempdir should not be exist
    End
  End

  Describe "read_pid_file()"
    It "reads pid file"
      When call read_pid_file pid "$FIXTURE/pid"
      The variable pid should eq 123
    End

    It "time out when pid file not found"
      sleep() { echo sleep; }
      When call read_pid_file pid "$FIXTURE/notpid" 3
      The variable pid should eq ""
      The lines of stdout should eq 3
    End
  End
End
