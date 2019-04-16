#shellcheck shell=sh

% FILE: "$SHELLSPEC_SPECDIR/fixture/time_log.txt"

Describe "libexec/reporter.sh"
  Include "$SHELLSPEC_LIB/libexec/reporter.sh"

  Describe "read_time_log()"
    It "does not read anything if file missing"
      When call read_time_log prefix "$FILE.not-exits"
      The variable prefix_real should be undefined
      The variable prefix_user should be undefined
      The variable prefix_sys should be undefined
      The status should be success
    End

    It "reads log data if file exists"
      When call read_time_log prefix "$FILE"
      The variable prefix_real should equal 1.23
      The variable prefix_user should equal 0.11
      The variable prefix_sys should equal 12.45
      The variable prefix_ should be undefined
      The status should be success
    End
  End
End
