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
  End

  Describe 'block style'
    Parameters:block
      1 2 \
          3
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
      for i in foo bar; \
      do
        %data "$i"
      done
      %data "b a z"
    End

    It "example $1"
      When call echo "$1"
      The output should eq "$1"
      The result of 'desc()' should eq "example $1"
    End
  End

  Describe 'matrix style'
    Parameters:matrix
      foo \
        "b a r"
      1 2 3
    End

    It "example $1 $2"
      When call echo "$1 $2"
      The output should be present
      The result of 'desc()' should eq "example $1 $2"
    End
  End

  Describe 'value style'
    Parameters:value foo bar baz \
      "[ contains spaces ]"

    It "example $1"
      When call echo "$1"
      The output should be present
      The result of 'desc()' should eq "example $1"
    End
  End

  Describe 'allow multiple parameters'
    Parameters:matrix
      foo bar
      1 2
    End

    Parameters
      baz 1
    End

    It "example $1 $2"
      When call echo "$1 $2"
      The output should be present
      The result of 'desc()' should eq "example $1 $2"
    End
  End

  Describe 'Using with data helper'
    Parameters
      a       A      Abc
      b       B      aBc
    End

    Data:expand
    #|abc
    End

    It "example $1 $2"
      When call @tr "$1" "$2"
      The output should eq "$3"
    End
  End
End
