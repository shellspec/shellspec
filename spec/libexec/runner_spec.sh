#shellcheck shell=sh disable=SC2004

% FIXTURE: "$SHELLSPEC_SPECDIR/fixture"

Describe "libexec/runner.sh"
  Include "$SHELLSPEC_LIB/libexec/runner.sh"

  change_permission() {
    chmod "$1" "$2"
    perm=$(ls -dl "$2")
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

    Before prepare
    prepare() { dir="$SHELLSPEC_TMPBASE/mktempdir_test"; }
    entry() { ls -dl "$dir"; }

    It "makes tempdir"
      When call mktempdir "$dir"
      The status should be success
      The result of 'entry()' should start with 'drwx------'
    End
  End

  Describe "rmtempdir()"
    Before prepare
    prepare() {
      dir="$SHELLSPEC_TMPBASE/rmtempdir_test"
      mktempdir "$dir"
      [ -d "$dir" ] && [ -w "$dir" ]
    }

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

  Describe "sleep_wait()"
    Before 'called_count=0'

    It "waits with sleep"
      sleep() { echo sleep; }
      callback() {
        called_count=$(($called_count + 1))
        [ "$called_count" -le 2 ]
      }
      When call sleep_wait callback
      The lines of stdout should eq 2
    End

    It "can specify a timeout"
      sleep() { echo sleep; }
      callback() { true; }
      When call sleep_wait 3 callback
      The lines of stdout should eq 3
      The status should be failure
    End
  End
End
