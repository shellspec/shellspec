#shellcheck shell=sh disable=SC2034

Describe 'skip sample'
  Describe 'calc()'
    calc() { echo "$(($*))"; }

    It 'can add'
      When call calc 1 + 1
      The output should eq 2
    End

    It 'can minus'
      When call calc 1 - 1
      The output should eq 0
    End

    # Skip examples of after this line in current example group
    Skip "decimal point can not be calculated"

    It 'can add decimal point'
      When call calc 1.1 + 1.1
      The output should eq 2.2
    End

    It 'can minus decimal point'
      When call calc 1.1 - 1.1
      The output should eq 0
    End

    Describe 'Multiplication' # example group is also skipped
      It 'can multiply decimal point'
        When call calc 1.1 '*' 1.1
        The output should eq 1.21
      End
    End
  End

  Describe 'status_to_singnal()'
    status_to_singnal() {
      if [ 128 -le "$1" ] && [ "$1" -le 192 ]; then
        echo "$(($1 - 128))"
      else
        # Not implemented: echo "status is out of range" >&2
        return 1
      fi
    }

    It 'can not convert status to singnal'
      When call status_to_singnal 0
      The status should be failure

      # Skip expection of after this line in current example
      Skip 'outputs error message is not implemented'
      The error should be present
    End

    # This example is going to execute
    It 'converts status to singnal'
      When call status_to_singnal 137
      The output should eq 9
    End
  End

  # "temporarily skip" can not hidden with "--skip-message quiet" option
  Describe 'temporarily skip'
    Example 'with Skip helper'
      Skip # without reason
      When call foo
      The status should be success
    End

    xExample 'with xExample (prepend "x")'
      When call foo
      The status should be success
    End

    xDescribe 'with xDescribe (prepend "x")'
      Example 'this is also skipped'
        When call foo
        The status should be success
      End
    End
  End

  Describe 'conditional skip'
    Example 'skip1'
      func() { return 0; }
      Skip if "function returns success" func
      When call echo ok
      The stdout should eq ok
    End

    Example 'skip2'
      func() { echo "skip"; }
      Skip if 'function returns "skip"' [ "$(func)" = "skip" ]
      When call echo ok
      The stdout should eq ok
    End
  End
End
