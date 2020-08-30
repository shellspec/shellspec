#shellcheck shell=sh disable=SC2016

Describe 'Directives'
  Describe '%printf'
    _printf() { %printf "$@"; }
    It 'calls printf builtin'
      When call _printf '%03d' "1"
      The output should eq "001"
    End
  End
End
