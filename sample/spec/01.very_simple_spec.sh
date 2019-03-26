#shellcheck shell=sh

It 'is simple'
  When call echo 'ok'
  The output should eq 'ok'
End
