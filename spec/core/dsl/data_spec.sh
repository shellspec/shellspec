#shellcheck shell=sh disable=SC2016

Describe 'Data helper'
  output() { cat -; }

  Describe 'with block'
    Data #comment
      #|aaa
      #|bbb
      #|ccc
      #|
    End

    Example 'reads data as stdin with call evaluation type'
      When call output
      The first line of output should eq 'aaa'
      The second line of output should eq 'bbb'
      The third line of output should eq "ccc"
      The lines of entire output should eq 4
    End

    Example 'reads data as stdin with invoke evaluation type'
      When invoke output
      The first line of output should eq 'aaa'
      The second line of output should eq 'bbb'
      The third line of output should eq "ccc"
      The lines of entire output should eq 4
    End

    Example 'reads data as stdin with run evaluation type'
      When run cat -
      The first line of output should eq 'aaa'
      The second line of output should eq 'bbb'
      The third line of output should eq "ccc"
      The lines of entire output should eq 4
    End
  End

  Describe 'with block with tr filter'
    Data | tr 'abc' 'ABC' # comment
      #|aaa
      #|bbb
      #|ccc
      #|
    End

    Example 'reads data as stdin with filter'
      When call output
      The first line of output should eq 'AAA'
      The second line of output should eq 'BBB'
      The third line of output should eq "CCC"
      The lines of entire output should eq 4
    End
  End

  Describe 'with name'
    func() { printf '%s\n' "$@"; }

    Example 'reads data from function'
      Data func a b c
      When call output
      The first line of output should eq 'a'
      The second line of output should eq 'b'
      The third line of output should eq "c"
      The lines of entire output should eq 3
    End

    Example 'reads data from function with filter'
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
      Data "abc"
      When call output
      The output should eq 'abc'
    End

    Example 'reads data from quoted string'
      Data 'abc'
      When call output
      The output should eq 'abc'
    End

    Example 'reads data from string with filter'
      Data "abc" | tr 'abc' 'ABC' # comment
      When call output
      The output should eq 'ABC'
    End
  End

  Example 'expands the variable'
    readonly name="world"

    Data
      #|Hello $name
    End

    When call output
    The output should eq 'Hello world'
  End

  Example ':raw not expands the variable'
    readonly name="world"

    Data:raw
      #|Hello $name
    End

    When call output
    The output should eq 'Hello $name'
  End
End
