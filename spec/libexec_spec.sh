#shellcheck shell=sh disable=SC2016,SC2004

% FIXTURE: "$SHELLSPEC_SPECDIR/fixture"
% INFILE: "$SHELLSPEC_SPECDIR/fixture/infile"
% TMPBASE: "$SHELLSPEC_TMPBASE"

Describe 'libexec.sh'
  Include "$SHELLSPEC_LIB/libexec.sh"

  Describe 'unixtime()'
    Before "SHELLSPEC_DATE=fake_date"

    Parameters
      "2019 08 18 08 17 44" 1566116264
      "2020 01 01 01 23 45" 1577841825
    End

    _unixtime() {
      eval "fake_date() { echo \"$2\"; }"
      unixtime "$1"
    }

    It 'gets unixtime'
      When call _unixtime ut "$1"
      The variable ut should eq "$2"
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

  Describe "edit_in_place()"
    prepare() { echo foo > "$TMPBASE/edit_in_place"; }
    Before prepare

    It "edits in place"
      When call edit_in_place "$TMPBASE/edit_in_place" @sed 's/f/F/g'
      The contents of file "$TMPBASE/edit_in_place" should eq "Foo"
    End
  End

  Describe "info()"
    Context 'when color mode enabled'
      BeforeRun 'SHELLSPEC_COLOR=1'
      It "outputs information"
        When run info foo bar
        The entire stdout should eq "${SHELLSPEC_ESC}[33mfoo bar${SHELLSPEC_ESC}[m${SHELLSPEC_LF}"
      End
    End

    Context 'when color mode disabled'
      BeforeRun 'SHELLSPEC_COLOR='
      It "outputs information"
        When run info foo bar
        The entire stdout should eq "foo bar${SHELLSPEC_LF}"
      End
    End
  End

  Describe "warn()"
    Context 'when color mode enabled'
      BeforeRun 'SHELLSPEC_COLOR=1'
      It "outputs warning"
        When run warn foo bar
        The entire stderr should eq "${SHELLSPEC_ESC}[33mfoo bar${SHELLSPEC_ESC}[m${SHELLSPEC_LF}"
      End
    End

    Context 'when color mode disabled'
      BeforeRun 'SHELLSPEC_COLOR='
      It "outputs warning"
        When run warn foo bar
        The entire stderr should eq "foo bar${SHELLSPEC_LF}"
      End
    End
  End

  Describe "error()"
    Context 'when color mode enabled'
      BeforeRun 'SHELLSPEC_COLOR=1'
      It "outputs error"
        When run error foo bar
        The entire stderr should eq "${SHELLSPEC_ESC}[1;31mfoo bar${SHELLSPEC_ESC}[m${SHELLSPEC_LF}"
      End
    End

    Context 'when color mode disabled'
      BeforeRun 'SHELLSPEC_COLOR='
      It "outputs error"
        When run error foo bar
        The entire stderr should eq "foo bar${SHELLSPEC_LF}"
      End
    End
  End

  Describe "abort()"
    It "aborts with output error"
      When run abort foo bar
      The stderr should include "foo bar"
      The status should be failure
    End
  End

  Describe "set_exit_status()"
    It "sets exit status"
      sleep() { echo sleep; }
      When call set_exit_status 123
      The status should eq 123
    End
  End

  Describe "nap()"
    sleep() { echo sleep "$@"; }

    Context 'when milliseconds not supported'
      BeforeRun SHELLSPEC_MSLEEP=''
      It "naps 0 seconds"
        When run nap
        The output should eq "sleep 0"
      End
    End

    Context 'when milliseconds supported'
      BeforeRun SHELLSPEC_MSLEEP=1
      It "naps 0.1 seconds"
        When run nap
        The output should eq "sleep 0.1"
      End
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

  Describe "sleep_wait_until()"
    Before called=""

    It "waits with sleep"
      sleep() { echo sleep; }
      condition() {
        called="$called."
        [ "${#called}" -gt 2 ]
      }
      When call sleep_wait_until condition
      The lines of stdout should eq 2
    End
  End

  Describe "timeout()"
    sleep() { :; }
    _timeout() { { ( sleep 1 ) & timeout 0 $!; } 2>/dev/null; }
    It "stops when timed out"
      When call _timeout 1
      The status should be success
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
