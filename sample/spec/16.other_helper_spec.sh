#shellcheck shell=sh

Describe 'Logger helper'
  Logger 'this is log'
  Example 'outputs log'
    Logger 'this is log'
  End
End
