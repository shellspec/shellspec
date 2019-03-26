#shellcheck shell=sh disable=SC2034

Describe 'expectation sample'
  It 'is succeeds because expectation is successful'
    foo() { echo "foo"; }
    When call foo
    The output should eq "foo" # this is expectation
  End

  It 'is failure because expectation is fail'
    foo() { echo "foo"; }
    When call foo
    The output should eq "bar"
  End

  Example 'you can write multiple expectations'
    foo() {
      echo "foo"
      value=123
      return 1
    }
    When call foo
    The output should eq "foo"
    The variable value should eq 123
    The status should eq 1
  End
End
