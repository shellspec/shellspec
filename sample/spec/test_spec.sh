#shellcheck shell=sh disable=SC2034

Describe 'example spec'
  Describe 'foo()'
    Context 'when second'
      calc() { echo "$@" | bc; }
      error() { exit 123; }
      set_var() { var=$1; }

      Example 'stdout matcher'
        When call calc 100 + 20 + 3
        The stdout should eq 1234
        The stdout should eq 1235
        It should equal 123 the stdout
      End

      Example 'include'
        When call calc 100 + 20 + 3
        The stdout should include 2
      End

      Example 'variable matcher'
        When call set_var 100
        The variable var should equal 100
      End

      Example 'should be success'
        When call true
        The status should be success
      End

      Example 'should be failure'
        When call false
        The status should be failure
      End
    End

    Context 'fourth third'
      foo() {
        echo a
        echo b
      }

      Example 'it is expect'
        When call foo
        The second line of stdout should equal b
      End
    End

    Context 'when third'
      Example 'it is expect'
      End
    End
  End
End
