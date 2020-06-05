#shellcheck shell=sh disable=SC2016

BeforeAll 'var=0'
Describe 'BeforeAll / AfterAll hook'
  BeforeAll '[ "$var" = 0 ] && var=$(($var+1))'
  AfterAll 'var=$(($var-1)) && [ "$var" = 0 ]'

  Specify "BeforeAll calls once per block"
    The variable var should eq 1
  End

  Specify "BeforeAll shares the state"
    The variable var should eq 1
  End
End

Example
  The variable var should eq 0
End
