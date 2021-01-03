#shellcheck shell=sh

# Each block (example group / example) runs within subshell.
# It mean that it works like lexical scope.

Describe 'scope example'
  foo() { echo "foo"; } # It can call from anywhere within this example group

  # By the way, you can only use shellspec DSL or define function here.
  # Of course it is possible to write freely within the defined function
  # but other code may breaks isolation of tests.

  It 'calls "foo"'
    When call foo
    The output should eq 'foo'
  End

  It 'defines "bar" function'
    bar() { echo "bar"; }
    When call bar
    The output should eq 'bar'
  End

  It 'can not call "bar" function, because different scope'
    When call bar
    The status should be failure # probably status is 127
    The stderr should be present # probably stderr is "bar: not found"
  End

  It 'redefines "foo" function'
    foo() { echo "FOO"; }
    When call foo
    The output should eq 'FOO'
  End

  It 'calls "foo" function of outer scope (not previous example)'
    When call foo
    The output should eq 'foo'
  End

  Describe 'sub block'
    foo() { echo "Foo"; }

    It 'calls "foo" function of upper scope'
      When call foo
      The output should eq 'Foo'
    End
  End
End
