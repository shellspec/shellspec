#shellcheck shell=sh

Describe 'addition'
  addition () { echo "$2" | "$1"; }

  Example 'using bc'
    When call addition bc '2+2'
    The output should eq 4
  End

  Example 'using dc'
    When call addition dc '2 2+p'
    The output should eq 4
  End
End
