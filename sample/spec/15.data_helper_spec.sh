#shellcheck shell=sh disable=SC2016

# Data helper is easy way to input data from stdin for evaluation.
# Removes `#|` from the beginning of the each line in the Data helper,
# the rest is the input data.

Describe 'Data helper'
  Example 'provide with Data helper block style'
    Data
      #|item1 123
      #|item2 456
      #|item3 789
    End
    When call awk '{total+=$2} END{print total}'
    The output should eq 1368
  End

  Example 'provide string with Data helper'
    Data '123 + 456 + 789'
    When call bc
    The output should eq 1368
  End

  Example 'provide from function with Data helper'
    data() {
      echo item1 123
      echo item2 456
      echo item3 789
    }
    Data data
    When call awk '{total+=$2} END{print total}'
    The output should eq 1368
  End

  Describe 'Data helper with filter'
    Example 'from block'
      Data | tr 'abc' 'ABC'
        #|aaa
        #|bbb
      End

      When call cat -
      The first line of output should eq 'AAA'
      The second line of output should eq 'BBB'
    End

    Example 'from function'
      func() { printf '%s\n' "$@"; }
      Data func a b c | tr 'abc' 'ABC' # comment
      When call cat -
      The first line of output should eq 'A'
      The second line of output should eq 'B'
      The third line of output should eq "C"
      The lines of entire output should eq 3
    End

    Example 'from string'
      Data 'abc'| tr 'abc' 'ABC' # comment
      When call cat -
      The output should eq ABC
    End
  End

  Describe 'variable expansion'
    Before 'item=123'

    Example 'not expand variable (default)'
      Data:raw
        #|item $item
      End
      When call cat -
      The output should eq 'item $item'
    End

    Example 'expand variable'
      Data:expand
        #|item $item
      End
      When call cat -
      The output should eq 'item 123'
    End

    # variable expansion is supported by block style only.
  End
End
