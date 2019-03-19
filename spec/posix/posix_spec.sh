#shellcheck shell=sh

Describe "posix/posix.sh"
  Describe "shellspec_unixtime()"
    Example "outputs unixtime"
      When call shellspec_unixtime
      The stdout should be valid as a number
    End

    Example "returns unixtime to variable"
      When call shellspec_unixtime ret
      The variable ret should be valid number
    End
  End
End