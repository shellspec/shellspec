# shellcheck shell=sh disable=SC2016,SC2286,SC2287,SC2288

Skip if "tmp directory is not executable" noexec_tmpdir

Mock mocked-command
  echo a
End

Specify "Mock helper can be used outer example group"
  When run mocked-command
  The output should eq a
End

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

    It "can be override"
      Mock mocked-command
        echo 123
      End

      When run func
      The output should eq 123
    End
  End

  It "can be restored"
    When run func
    The output should eq abc
  End

  Mock mocked-command
    %putsn foo
    # shellcheck disable=SC2034
    var=123
    %preserve var
  End

  It "can use directives"
    When run mocked-command
    The output should eq foo
    The variable var should eq 123
  End

  foo() {
    echo foo
  }

  It "can use directives"
    When run foo
    The output should eq foo
  End
End
