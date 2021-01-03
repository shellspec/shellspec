#shellcheck shell=sh

# shellspec has Before and After hook.
# Those hooks are execute for each example (It/Example/Specify).
# There is no hooks execute for each example group (Describe/Context).
# In other words, There is no BeforeAll / AfterAll hooks. It is design policy.

Describe 'before / after hook example'
  Describe '1: before hook'
    setup() { value=10; }
    Before 'setup'

    add_value() {
      value=$((value + $1))
      echo "$value"
    }

    It 'is called before execute example'
      When call add_value 10
      The output should eq 20
    End

    It 'is called for each example'
      When call add_value 100
      The output should eq 110
    End
  End

  Describe '2: before hook'
    setup1() { value1=10; }
    setup2() { value2=20; }
    Before 'setup1' 'setup2'

    add_values() {
      echo "$((value1 + value2))"
    }

    It 'can register multiple'
      When call add_values
      The output should eq 30
    End
  End

  Describe '3: before hook'
    Before 'value=10'

    echo_value() { echo "$value"; }

    It 'can also specify code instead of function'
      When call echo_value
      The output should eq 10
    End
  End

  Describe '4: before hook'
    setup() { false; } # setup fails
    Before 'setup'
    echo_ok() { echo ok; }

    It 'is fails because before hook fails'
      When call echo_ok
      The output should eq 'ok'
    End

    # This behavior can be used to verify initialization of before hook.
  End

  Describe '5: after hook'
    cleanup() { :; } # clean up something
    Before 'cleanup'

    It 'is called after execute example'
      When call echo ok
      The output should eq 'ok'
    End
  End
End
