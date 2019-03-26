#shellcheck shell=sh

Describe 'Def helper'
  Example 'define a function that output value'
    Def func value
    When call func
    The output should eq value
  End
End

Describe 'Logger helper'
  Logger 'this is log'
  Example 'outputs log'
    Logger 'this is log'
  End
End
