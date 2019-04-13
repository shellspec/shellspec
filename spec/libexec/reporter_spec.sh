#shellcheck shell=sh

% FILE: "$SHELLSPEC_SPECDIR/fixture/read_log.txt"

Describe "libexec/reporter.sh"
  Include "$SHELLSPEC_LIB/libexec/reporter.sh"

  Describe "read_log()"
    It "does not read anything if file missing"
      When call read_log prefix "$FILE.not-exits"
      The variable prefix_name1 should be undefined
      The variable prefix_name2 should be undefined
      The status should be success
    End

    It "reads log data if file exists"
      When call read_log prefix "$FILE"
      The variable prefix_name1 should equal value1
      The variable prefix_name2 should equal value2
      The status should be success
    End
  End
End
