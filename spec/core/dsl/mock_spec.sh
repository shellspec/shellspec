#shellcheck shell=sh disable=SC2016

Describe 'Mock helper'
  Mock mocked-command
    echo abc
  End

  func() {
    mocked-command
  }

  It "runs command-based mock"
    When run func
    The output should eq abc
  End

  Describe
    Mock mocked-command
      echo ABC
    End

    It "can be override"
      When run func
      The output should eq ABC
    End
  End

  It "can be restored"
    When run func
    The output should eq abc
  End

  Describe
    Mock mocked-command
      %= foo
      # shellcheck disable=SC2034
      var=123
      %preserve var
    End

    It "can use directives"
      When run mocked-command
      The output should eq foo
      The variable var should eq 123
    End
  End
End
