#shellcheck shell=sh

Describe 'support-bin.sh'
  It 'executes external command'
    When run script spec/support/bin/printf ok
    The output should eq ok
  End
End
