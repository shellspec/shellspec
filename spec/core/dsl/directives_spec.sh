#shellcheck shell=sh disable=SC2016

Describe 'Directives'
  Describe '%printf'
    _printf() { %printf "$@"; }
    It 'calls printf builtin'
      When call _printf '%03d' "1"
      The output should eq "001"
    End
  End

  Describe '%sleep'
    _sleep() { %sleep "$@"; }
    It 'calls sleep builtin'
      When call _sleep 0
      The status should eq 0
    End
  End
End
