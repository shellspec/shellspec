#shellcheck shell=sh

Describe 'include helper sample'
  Describe 'include helper'
    # Include helper is include external file immediately.
    Include ./lib.sh

    Example 'include external file'
      When call calc 1 + 2
      The output should eq 3
    End
  End
End
