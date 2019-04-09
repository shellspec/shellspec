#shellcheck shell=sh

Describe "libexec/executer.sh"
  Include "$SHELLSPEC_LIB/libexec/executor.sh"

  Describe "time_result()"
    It "parses real 0.01 as time result"
      When call time_result "real   0.01"
      The stdout should equal "real   0.01"
      The status should be success
    End

    It "parses user 0.01 as time result"
      When call time_result "user   0.01"
      The stdout should equal "user   0.01"
      The status should be success
    End

    It "parses sys 0.01 as time result"
      When call time_result "sys   0.01"
      The stdout should equal "sys   0.01"
      The status should be success
    End

    It "does not parse real 0.01a as time result"
      When call time_result "real   0.01a"
      The status should be failure
    End
  End
End
