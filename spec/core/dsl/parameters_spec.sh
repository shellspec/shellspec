#shellcheck shell=sh disable=SC2016

Describe 'Parameters helper'
  desc() {
    echo "${SHELLSPEC_DESCRIPTION##*$SHELLSPEC_VT}"
  }

  Describe 'block style'
    Parameters
      # value1 value2 answer
        1      2      3
        2      3      5
    End

    It "example $1 + $2" tag
      When call echo "$(($1 + $2))"
      The output should eq "$3"
      The result of 'desc()' should eq "example $1 + $2"
    End

    Parameters:block
      1 2 3
      2 3 5
    End

    It "example $1 + $2"
      When call echo "$(($1 + $2))"
      The output should eq "$3"
      The result of 'desc()' should eq "example $1 + $2"
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
      The result of 'desc()' should eq "example $1"
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
      The result of 'desc()' should eq "example $1 $2"
    End
  End

  Describe 'value style'
    Parameters:value foo bar baz

    It "example $1"
      When call echo "$1"
      The output should be present
      The result of 'desc()' should eq "example $1"
    End
  End
End
