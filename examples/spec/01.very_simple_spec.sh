#shellcheck shell=sh

It 'is simple'
  When call echo 'ok'
  The output should eq 'ok'
End

Describe 'lib.sh'
  Include ./lib.sh # include other script

  Describe 'calc()'
    It 'calculates'
      When call calc 1 + 1
      The output should eq 2
    End
  End
End
