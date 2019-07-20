#shellcheck shell=sh disable=SC2016,SC2004

% INFILE: "$SHELLSPEC_SPECDIR/fixture/infile"

Describe 'libexec.sh'
  Include "$SHELLSPEC_LIB/libexec.sh"

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
    parepare() {
      called=""
      begin_time=$(date +%s)
    }
    Before parepare

    It "waits with sleep"
      sleep() { echo sleep; }
      condition() {
        called="$called."
        [ "${#called}" -le 2 ]
      }
      When call sleep_wait condition
      The lines of stdout should eq 2
    End

    It "can specify a timeout"
      date() { echo "$(($begin_time + ${#called}))"; }
      condition() { called="$called."; }
      When call sleep_wait 3 condition
      The status should be failure
      The value "${#called}" should eq 3
    End
  End
End
