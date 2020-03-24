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
      #|spec/libexec/general_spec.sh:@1-1
      #|spec/libexec/reporter_spec.sh:@1-11-4-1
    End

    _read_quickfile() {
      while read_quickfile "$@"; do
        eval "echo $(printf '$%s ' "$@")"
      done
    }

    It "reads quickfile"
      When call _read_quickfile line specfile
      The word 1 of line 1 of stdout should eq "spec/libexec/general_spec.sh:@1-1"
      The word 2 of line 1 of stdout should eq "spec/libexec/general_spec.sh"
      The word 1 of line 2 of stdout should eq "spec/libexec/reporter_spec.sh:@1-11-4-1"
      The word 2 of line 2 of stdout should eq "spec/libexec/reporter_spec.sh"
    End

    It "reads quickfile with id"
      When call _read_quickfile line specfile id
      The word 1 of line 1 of stdout should eq "spec/libexec/general_spec.sh:@1-1"
      The word 2 of line 1 of stdout should eq "spec/libexec/general_spec.sh"
      The word 3 of line 1 of stdout should eq "@1-1"
      The word 1 of line 2 of stdout should eq "spec/libexec/reporter_spec.sh:@1-11-4-1"
      The word 2 of line 2 of stdout should eq "spec/libexec/reporter_spec.sh"
      The word 3 of line 2 of stdout should eq "@1-11-4-1"
    End
  End

  Describe "match_files_pattern()"
    Parameters
      success "spec"        "spec"
      success "spec"        "spec/"
      success "spec"        "spec/file"
      success "spec/"       "spec/file"
      success "spec/file"   "spec/file"
      success "spec/[file]" "spec/[file]"
      failure "spec/file"   "spec/file.ext"
      failure "spec"        "foo"
      failure "spec"        "spec1"
    End

    check_match_files_pattern() {
      pattern=''
      match_files_pattern pattern "$1"
      shellspec_match "$2" "$pattern"
    }

    It "checks if the path matches the pattern (pattern: $2, path: $3)"
      When call check_match_files_pattern "$2" "$3"
      The status should be "$1"
    End
  End
End
