#shellcheck shell=sh disable=SC2016

% FIXTURE: "$SHELLSPEC_HELPERDIR/fixture"
% FILE: "$SHELLSPEC_TMPBASE/status"

Describe "shellspec-precheck.sh"
  create_status_file() {
    echo "$1" > "$FILE"
  }

  Context "when the precheck callback succeeds"
    Before 'export MODE=success'
    Before 'create_status_file 100'
    It 'loads env file'
      When run script ./libexec/shellspec-prechecker.sh --status-file="$FILE" "$FIXTURE/precheck.sh" "$FIXTURE/empty"
      The output should eq "precheck"
      The status should be success
      The contents of file "$FILE" should be blank
    End
  End

  Context "when the precheck callback return zero"
    Before 'export MODE=return:0'
    Before 'create_status_file 100'
    It 'loads env file'
      When run script ./libexec/shellspec-prechecker.sh --status-file="$FILE" "$FIXTURE/precheck.sh" "$FIXTURE/empty"
      The output should eq "precheck"
      The status should eq 0
      The contents of file "$FILE" should be blank
    End
  End

  Context "when the precheck callback return non-zero"
    Before 'export MODE=return:2'
    It 'loads env file'
      When run script ./libexec/shellspec-prechecker.sh --status-file="$FILE" "$FIXTURE/precheck.sh" "$FIXTURE/empty"
      The output should eq "precheck"
      The status should eq 2
      The contents of file "$FILE" should eq 2
    End
  End

  Context "when the precheck callback exits zero"
    Before 'export MODE=exit:0'
    Before 'create_status_file 100'
    It 'loads env file'
      When run script ./libexec/shellspec-prechecker.sh --status-file="$FILE" "$FIXTURE/precheck.sh" "$FIXTURE/empty"
      The output should eq "precheck"
      The status should eq 0
      The contents of file "$FILE" should eq 0
    End
  End

  Context "when the precheck callback exits non-zero"
    Before 'export MODE=exit:3'
    It 'loads env file'
      When run script ./libexec/shellspec-prechecker.sh --status-file="$FILE" "$FIXTURE/precheck.sh" "$FIXTURE/empty"
      The output should eq "precheck"
      The status should eq 3
      The contents of file "$FILE" should eq 3
    End
  End

  Context "when an error occurs"
    Before 'export MODE=abort:127'
    Before 'create_status_file 100'
    It 'loads env file'
      When run script ./libexec/shellspec-prechecker.sh --status-file="$FILE" --warn-fd=1 "$FIXTURE/precheck.sh" "$FIXTURE/empty"
      The output should include "shellspec_precheck_loaded"
      The status should be failure
      The contents of file "$FILE" should be blank
      # The contents of file "$FILE" should eq 127 # abort in the future
    End
  End
End
