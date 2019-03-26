#shellcheck shell=sh disable=SC2034

Describe 'include helper sample'
  Describe 'include helper'
    Include ./lib.sh
    Example 'include external file'
      When call calc 1 + 2
      The output should eq 3
    End
  End

  # Include helper is include external file per each example.
  # It means Include is equivalent to this code.
  Describe 'before helper'
    Before '. ./lib.sh'
    Example 'include external file'
      When call calc 1 + 2
      The output should eq 3
    End
  End
End
