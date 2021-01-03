#shellcheck shell=sh

Describe 'Logger helper'
  %logger 'this is log'
  Example 'outputs log'
    %logger 'this is log'
  End
End
