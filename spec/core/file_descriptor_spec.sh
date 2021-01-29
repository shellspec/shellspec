#shellcheck shell=sh disable=SC2004,SC2016

Describe "core/file_descriptor.sh"
  Describe "shellspec_open_file_descriptors()"
    mock() {
      shellspec_open_file_descriptor() { echo "$@"; }
    }
    BeforeRun mock SHELLSPEC_FDVAR_AVAILABLE=''

    It 'opens file descriptors'
      When run shellspec_open_file_descriptors 1:@:A:2
      The word 1 of line 1 should eq "1"
      The word 1 of line 2 should eq "2"
    End

    Context "For shells that can assign file descriptors to variables"
      BeforeRun SHELLSPEC_FDVAR_AVAILABLE=1

      It 'opens file descriptors'
        When run shellspec_open_file_descriptors 1:@:A:2
        The word 1 of line 1 should eq "1"
        The word 1 of line 2 should eq "{A}"
        The word 1 of line 3 should eq "2"
      End
    End
  End

  Describe "shellspec_open_file_descriptor()"
    open_file_descriptor() {
      shellspec_open_file_descriptor "$@"
      echo "test" >&6
    }

    It 'opens the file descriptor'
      When call open_file_descriptor 6 "$SHELLSPEC_WORKDIR/fd-test6"
      The status should be success
    End
  End

  Describe "shellspec_close_file_descriptors()"
    mock() {
      shellspec_close_file_descriptor() { echo "$@"; }
    }
    BeforeRun mock SHELLSPEC_FDVAR_AVAILABLE=''

      It 'closes file descriptors'
      When run shellspec_close_file_descriptors 1:@:A:2
      The word 1 of line 1 should eq "1"
      The word 1 of line 2 should eq "2"
    End

    Context "For shells that can assign file descriptors to variables"
      BeforeRun SHELLSPEC_FDVAR_AVAILABLE=1

      It 'closes file descriptors'
        When run shellspec_close_file_descriptors 1:@:A:2
        The word 1 of line 1 should eq "1"
        The word 1 of line 2 should eq "{A}"
        The word 1 of line 3 should eq "2"
      End
    End
  End

  Describe "shellspec_close_file_descriptor()"
    setup() {
      exec 7>"$SHELLSPEC_WORKDIR/fd-test7"
    }
    Before setup

    close_file_descriptor() {
      shellspec_close_file_descriptor "$1"
      echo "test" >&7
    }

    It 'closes the file descriptor'
      When call close_file_descriptor 7
      The status should be failure
      The error should be present
    End
  End
End
