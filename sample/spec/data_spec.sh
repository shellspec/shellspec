#shellcheck shell=sh

Describe 'Data helper'
  output() { cat -; }

  Describe 'with block'
    Example 'output read data'
      Data
        #|aaa
        #|bbb
        #|ccc
        #|
      End

      When call output
      The first line of output should eq 'aaa'
      The second line of output should eq 'bbb'
      The third line of output should eq "ccc"
      The lines of entire output should eq 4
    End

    Example 'output read data with tr'
      Data | tr '[a-z]' '[A-Z]'
        #|aaa
        #|bbb
        #|ccc
        #|
      End

      When call output
      The first line of output should eq 'AAA'
      The second line of output should eq 'BBB'
      The third line of output should eq "CCC"
      The lines of entire output should eq 4
    End
  End

  Describe 'with name'
    func() { printf '%s\n' "$@"; }

    Example 'output read data'
      Data func a b c
      When call output
      The first line of output should eq 'a'
      The second line of output should eq 'b'
      The third line of output should eq "c"
      The lines of entire output should eq 3
    End

    Example 'output read data with tr'
      Data func a b c | tr '[a-z]' '[A-Z]' # comment
      When call output
      The first line of output should eq 'A'
      The second line of output should eq 'B'
      The third line of output should eq "C"
      The lines of entire output should eq 3
    End
  End
End
