#shellcheck shell=sh disable=SC2016

Describe 'Data helper'
  output() { cat -; }

  Describe 'sample1'
    Data
      #|item1 123
      #|item2 246
      #|item3 369
    End

    Example 'sum the second field by awk'
      When call awk '{total+=$2} END{print total}'
      The output should eq 738
    End
  End

  Describe 'sample2'
    Data '123 + 246 + 369'
    Example 'calculate by bc'
      When call bc
      The output should eq 738
    End
  End

  Describe 'sample3'
    data() {
      echo 123
      echo 246
      echo 369
    }

    sum() {
      total=0
      while read -r value; do
        total=$((total + value))
      done
      echo "$total"
    }

    Data data
    Example 'calculate by sum function from data function'
      When call sum
      The output should eq 738
    End
  End

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
      Data | tr 'abc' 'ABC'
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
      Data func a b c | tr 'abc' 'ABC' # comment
      When call output
      The first line of output should eq 'A'
      The second line of output should eq 'B'
      The third line of output should eq "C"
      The lines of entire output should eq 3
    End
  End

  Describe 'with string'
    Example 'reads data from string'
      Data '1 + 2'
      When call bc
      The output should eq 3
    End
  End
End
