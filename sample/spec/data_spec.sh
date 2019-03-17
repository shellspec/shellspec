#shellcheck shell=sh

Describe 'Data helper'
  output() { cat -; }

  Describe 'with block'
    Data #sample
      #|aaa
      #|bbb
      #|ccc
      #|
    End

    Example 'output read data'
      When call output
      The first line of output should eq 'aaa'
      The second line of output should eq 'bbb'
      The third line of output should eq "ccc"
      The lines of entire output should eq 4
    End
  End

  Describe 'with name'
    func() { printf '%s\n' "$@"; }
    Data func a b c

    Example 'output read data'
      When call output
      The first line of output should eq 'a'
      The second line of output should eq 'b'
      The third line of output should eq "c"
      The lines of entire output should eq 3
    End
  End
End
