#shellcheck shell=sh disable=SC2016

# %text directive is easy way to output text like here document.
# Removes `#|` from the beginning of the each line in the %text directive,
# the rest is the output text.

Describe '%text directive'
  It 'outputs texts'
    output() {
      echo "start" # you can write code here
      %text
      #|aaa
      #|bbb
      #|ccc
      echo "end" # you can write code here
    }
    When call output
    The line 1 of output should eq 'start'
    The line 2 of output should eq 'aaa'
    The line 3 of output should eq 'bbb'
    The line 4 of output should eq "ccc"
    The line 5 of output should eq 'end'
  End

  It 'sets to variable'
    output() {
      texts=$(
        %text
        #|aaa
        #|bbb
        #|ccc
      )
      echo "$texts"
    }
    When call output
    The line 1 of output should eq 'aaa'
    The line 2 of output should eq 'bbb'
    The line 3 of output should eq "ccc"
  End

  It 'outputs texts with filter'
    output() {
      %text | tr 'a-z_' 'A-Z_'
      #|abc
    }
    When call output
    The output should eq 'ABC'
  End

  Describe 'variable expantion'
    Before 'text=abc'

    Example 'not expand variable (default)'
      output() {
        %text:raw
        #|$text
      }
      When call output
      The output should eq '$text'
    End

    Example 'expand variable'
      output() {
        %text:expand
        #|$text
      }
      When call output
      The output should eq 'abc'
    End
  End

  It 'outputs texts with more complex code'
    output() {
      if true; then
        for i in 1 2 3 4 5; do
          %text:expand | tr 'a-z_' 'A-Z_'
          #|value $((i * 10))
        done
      else
        %text
        #|text
      fi
    }
    When call output
    The line 1 of output should eq 'VALUE 10'
    The line 2 of output should eq 'VALUE 20'
    The line 3 of output should eq 'VALUE 30'
    The line 4 of output should eq "VALUE 40"
    The line 5 of output should eq 'VALUE 50'
  End
End
