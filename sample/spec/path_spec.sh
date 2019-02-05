#shellcheck shell=sh

Describe 'path'
  Example 'absolute path'
    The path "/etc/hosts" should be exist
  End

  Example 'alias path'
    Path hosts="/etc/hosts"
    The path "hosts" should be exist
  End
End
