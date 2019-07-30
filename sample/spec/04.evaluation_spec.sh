#shellcheck shell=sh disable=SC2016

Describe 'evaluation sample'
  Describe 'call evaluation'
    It 'calls function'
      foo() { echo "foo"; }
      When call foo # this is evaluation
      The output should eq "foo"
    End

    It 'calls external command also'
      When call expr 1 + 2
      The output should eq 3
    End

    It 'calls the defined function instead of external command that same name'
      expr() { echo "be called"; }
      When call expr 1 + 2
      The output should eq "be called"
    End

    It 'must be one call each example'
      When call echo 1
      When call echo 2 # can not be called more than once.
      The output should eq 1
    End

    It 'not calling is allowed'
      The value 123 should eq 123
    End

    It 'can not be called after expectation'
      The value 123 should eq 123
      When call echo 1 # can not be called after expectation.
    End

    It 'calls external command'
      expr() { echo "not called"; }
      When call command expr 1 + 2
      The output should eq 3
    End
  End

  Describe 'invoke evaluation'
    It 'can trap exit'
      abort() { exit 1; }
      When invoke abort # if use "call evaluation", shellspec is terminate
      The status should be failure
    End

    It 'can not modify variable because it run with in subshell'
      set_value() { SHELLSPEC_VERSION=$1; }
      When invoke set_value 'no-version'
      The value "$SHELLSPEC_VERSION" should not eq 'no-version'
    End

    It 'calls shellspec_around_invoke hook'
      shellspec_around_invoke() {
        # You can temporarily redefine function here
        # redefined function is restored after invoke evaluation
        # because invoke evaluation runs with in subshell
        echo before
        "$@" # run "echo 123"
        echo after
      }
      When invoke echo 123
      The line 1 of output should eq 'before'
      The line 2 of output should eq 123
      The line 3 of output should eq 'after'
    End
  End
End
