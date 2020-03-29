#shellcheck shell=sh disable=SC2016,SC2004

% FIXTURE: "$SHELLSPEC_SPECDIR/fixture"
% INFILE: "$SHELLSPEC_SPECDIR/fixture/infile"

Describe 'libexec.sh'
  Include "$SHELLSPEC_LIB/libexec.sh"

  Describe 'unixtime()'
    date() { echo "2019 08 18 08 17 44"; }
    It 'gets unixtime'
      When call unixtime ut
      The variable ut should eq 1566116264
    End
  End

  Describe 'is_specfile()'
    Before SHELLSPEC_PATTERN="*_spec.sh"

    It 'returns success when pattern matches the filename'
      When call is_specfile "test_spec.sh"
      The status should be success
    End

    It 'returns success when pattern matches the filename with range'
      When call is_specfile "test_spec.sh:10"
      The status should be success
    End

    It 'returns failure when pattern not matches the filename'
      When call is_specfile "test.sh"
      The status should be failure
    End
  End

  Describe 'found_specfile()'
    callback() {
      echo "path:$1"
      echo "file:$2"
      echo "range:${3-[unset]}"
    }

    It 'calls callback with no range'
      When call found_specfile callback "a_spec.sh"
      The line 1 of output should eq "path:a_spec.sh"
      The line 2 of output should eq "file:a_spec.sh"
      The line 3 of output should eq "range:[unset]"
    End

    It 'calls callback with range'
      When call found_specfile callback "a_spec.sh:1:2:@1-2"
      The line 1 of output should eq "path:a_spec.sh:1:2:@1-2"
      The line 2 of output should eq "file:a_spec.sh"
      The line 3 of output should eq "range:1 2 @1-2"
    End
  End

  Describe 'find_specfiles()'
    Before SHELLSPEC_INFILE="$INFILE"
    shellspec_find_files() { shift; printf '%s\n' "$@"; }

    It 'find files from arguments'
      When call find_specfiles _ file1 dir1
      The line 1 of output should eq "file1"
      The line 2 of output should eq "dir1"
    End

    It 'find files from INFILE'
      When call find_specfiles _ -
      The line 1 of output should eq "file2"
      The line 2 of output should eq "dir2"
    End
  End

  Describe "set_exit_status()"
    It "sets exit status"
      sleep() { echo sleep; }
      When call set_exit_status 123
      The status should eq 123
    End
  End

  Describe "sleep_wait()"
    Before called=""

    It "waits with sleep"
      sleep() { echo sleep; }
      condition() {
        called="$called."
        [ "${#called}" -le 2 ]
      }
      When call sleep_wait condition
      The lines of stdout should eq 2
    End
  End

  Describe "signal()"
    posix_kill() { eval SHELLSPEC_KILL=echo && true; }
    non_posix_kill() { eval SHELLSPEC_KILL=echo && false; }

    It "calls kill (posix)"
      BeforeCall SHELLSPEC_KILL=posix_kill
      When call signal -TERM 0
      The stdout should eq "-TERM 0"
    End

    It "calls kill (non-posix)"
      BeforeCall SHELLSPEC_KILL=non_posix_kill
      When call signal -TERM 0
      The stdout should eq "-s TERM 0"
    End
  End

  Describe "read_quickfile()"
    Data
      #|spec/libexec/general_spec.sh:@1-1:failed
      #|spec/libexec/general_spec.sh:@1-2:warn
      #|spec/libexec/reporter_spec.sh:@1-11-4-1:todo
      #|spec/libexec/reporter_spec.sh:@1-11-4-2:fixed
    End

    _read_quickfile() {
      while read_quickfile "$@"; do
        eval "echo \$$1 ${2:+\$$2}"
      done
    }

    It "reads quickfile"
      When call _read_quickfile line
      The line 1 of stdout should eq "spec/libexec/general_spec.sh:@1-1"
      The line 2 of stdout should eq "spec/libexec/general_spec.sh:@1-2"
      The line 3 of stdout should eq "spec/libexec/reporter_spec.sh:@1-11-4-1"
      The line 4 of stdout should eq "spec/libexec/reporter_spec.sh:@1-11-4-2"
      The lines of stdout should eq 4
    End

    It "reads quickfile with state"
      When call _read_quickfile line state
      The line 1 of stdout should eq "spec/libexec/general_spec.sh:@1-1 failed"
      The line 2 of stdout should eq "spec/libexec/general_spec.sh:@1-2 warn"
      The line 3 of stdout should eq "spec/libexec/reporter_spec.sh:@1-11-4-1 todo"
      The line 4 of stdout should eq "spec/libexec/reporter_spec.sh:@1-11-4-2 fixed"
      The lines of stdout should eq 4
    End

    It "reads failed quick data only"
      When call _read_quickfile line state 1
      The line 1 of stdout should eq "spec/libexec/general_spec.sh:@1-1 failed"
      The line 2 of stdout should eq "spec/libexec/general_spec.sh:@1-2 warn"
      The lines of stdout should eq 2
    End
  End

  Describe "includes_path()"
    Parameters
      success "spec" "spec"
      success "spec" "spec/"
      success "spec/" "spec"
      failure "specify" "spec"
      success "spec/general_spec.sh" "spec"
      failure "specify/general_spec.sh" "spec"
      success "spec/libexec/general_spec.sh" "spec"
      success "spec/libexec/general_spec.sh" "spec/libexec"
      success "spec/libexec/general_spec.sh" "spec/libexec/general_spec.sh"
    End

    It "checks include path (target: $2, path: $3)"
      When call includes_path "$2" "$3"
      The status should be "$1"
    End
  End

  Describe "match_quick_data()"
    It "accepts multiple arguments"
      When call match_quick_data "spec/general_spec.sh" "specify" "spec"
      The status should be success
    End

    Parameters
      success "spec/general_spec.sh:@1-1" "spec"
      success "spec/general_spec.sh:@1-1" "spec/general_spec.sh"
      success "spec/general_spec.sh:@1-1" "spec/general_spec.sh:@1-1"
      failure "spec/general_spec.sh:@1-11" "spec/general_spec.sh:@1-1"
      success "spec/general_spec.sh:@1-1-1" "spec/general_spec.sh:@1-1"
      success "spec/general_spec.sh:@1-1" "spec/general_spec.sh:@2:@1-1"
      failure "spec/general_spec.sh:@1-1" "spec/general_spec.sh:3"
      success "spec/general_spec.sh:@1-1" "spec/general_spec.sh:3:@1"
    End

    It "checks if it matches the quick data (quick data: $2, path: $3)"
      When call match_quick_data "$2" "$3"
      The status should be "$1"
    End
  End
End
