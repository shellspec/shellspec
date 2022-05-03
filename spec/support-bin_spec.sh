# shellcheck shell=sh disable=SC2016,SC2286,SC2287,SC2288

Describe 'support-bin.sh'
  It 'executes external command'
    When run script helper/support/bin/printf ok
    The output should eq ok
  End
End
