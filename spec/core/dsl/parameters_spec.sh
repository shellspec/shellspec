#shellcheck shell=sh disable=SC2016

Describe 'Parameters helper'
  Describe 'block style'
    Parameters
      # value1 value2 answer
        1      2      3
        2      3      5
    End

    It "example $1 + $2"
      When call echo "$(($1 + $2))"
      The output should eq "$3"
    End

    Parameters:block
      1 2 3
      2 3 5
    End

    It "example $1 + $2"
      When call echo "$(($1 + $2))"
      The output should eq "$3"
    End
  End

  Describe 'dynamic style'
    Parameters:dynamic
      for i in foo bar; do
        %data "$i"
      done
      %data baz
    End

    It "example $1"
      When call echo "$1"
      The output should eq "$1"
    End
  End

  Describe 'matrix style'
    Parameters:matrix
      foo bar
      1 2 3
    End

    It "example $1 $2"
      When call echo "$1 $2"
      The output should be present
    End
  End
End
