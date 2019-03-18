#shellcheck shell=sh disable=SC2034

Describe 'evaluation'
  addition () { echo "$*" | bc; }

  Describe 'call'
    Example 'call function'
      When call addition '2+2'
      The output should eq 4
    End

    Example 'call evaluatable string'
      When call 'echo "$*" | bc' '2+2'
      The output should eq 4
    End
  End

  Describe 'run'
    date () { echo 'not called'; }

    Example 'run external command'
      When run date '+%s'
      The output should be valid as number
    End
  End

  Describe 'invoke'
    abort() { exit 1; }
    set_value() { value=$1; }

    Example 'invoke can trap exit'
      When invoke abort
      The status should be failure
    End

    Example 'invoke not modify variable.'
      When invoke set_value 123
      The variable value should not equal 123
    End
  End
End
