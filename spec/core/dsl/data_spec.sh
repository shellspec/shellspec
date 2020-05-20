#shellcheck shell=sh disable=SC2016

% FIXTURE: "$SHELLSPEC_SPECDIR/fixture"

Describe 'Data helper'
  output() { cat -; }

  Describe 'block style'
    Data #comment
      #|aaa
      #|bbb
      #|ccc
      #|
    End

    It 'reads data as stdin with call evaluation type'
      When call output
      The first line of output should eq 'aaa'
      The second line of output should eq 'bbb'
      The third line of output should eq "ccc"
      The lines of entire output should eq 4
    End

    It 'reads data as stdin with run evaluation type'
      When run output
      The first line of output should eq 'aaa'
      The second line of output should eq 'bbb'
      The third line of output should eq "ccc"
      The lines of entire output should eq 4
    End

    It 'reads data as stdin with filter'
      Data | tr 'abc' 'ABC' # comment
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

    Describe 'variable expansion'
      Before name="world"

      It 'not expands the variable'
        Data
          #|Hello $name
        End
        When call output
        The output should eq 'Hello $name'
      End

      It ':raw not expands the variable'
        Data:raw
          #|Hello $name
        End
        When call output
        The output should eq 'Hello $name'
      End

      It ':expand expands the variable'
        Data:expand
          #|Hello $name
        End
        When call output
        The output should eq 'Hello world'
      End
    End
  End

  Describe 'function style'
    foo() { printf '%s\n' "$@"; }

    It 'reads data as stdin from function'
      Data foo a b c
      When call output
      The first line of output should eq 'a'
      The second line of output should eq 'b'
      The third line of output should eq "c"
      The lines of entire output should eq 3
    End

    It 'reads data as stdin from function with filter'
      Data foo a b c | tr 'abc' 'ABC' # comment
      When call output
      The first line of output should eq 'A'
      The second line of output should eq 'B'
      The third line of output should eq "C"
      The lines of entire output should eq 3
    End
  End

  Describe 'string style'
    It 'reads data as stdin from string'
      Data "abc"
      When call output
      The output should eq 'abc'
    End

    It 'reads data as stdin from quoted string'
      Data 'abc'
      When call output
      The output should eq 'abc'
    End

    It 'reads data as stdin from string with filter'
      Data "abc" | tr 'abc' 'ABC' # comment
      When call output
      The output should eq 'ABC'
    End

    Describe 'file style'
      It 'reads data from file'
        Data < "$FIXTURE/file"
        When call output
        The output should eq 'this is not empty'
      End
    End
  End
End
