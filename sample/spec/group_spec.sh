#shellcheck shell=sh disable=SC2034

Describe '1'
  foo() { var=foo; echo foo; }

  Describe '1:1'
    bar() { echo bar; }

    Example '1:1:1'
      When call foo
      The output should equal foo
      The variable var should equal foo
    End

    Example '1:1:2'
      When call bar
      The output should equal bar
      The variable var should be undefined
    End
  End

  Describe '1:2'
    Example '1:2:1'
      When call foo
      The output should equal foo
    End

    Example '1:2:2'
      When call bar # can not call bar
      The output should not equal bar
      The status should equal 127
      The error should be present
    End
  End

  Describe '1:3'
    foo() { echo FOO; } # override foo

    Example '1:3:1'
      When call foo
      The output should equal FOO
    End
  End
End
