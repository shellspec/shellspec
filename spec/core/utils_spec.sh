#shellcheck shell=sh

Describe "core/utils.sh"
  Describe 'shellspec_get_nth()'
    It 'fetch nth value seperate by ,'
      When call shellspec_get_nth var 3 ',' "a,b,c,d,e"
      The variable var should equal c
    End

    It 'fetch nth value seperate by space'
      When call shellspec_get_nth var 3 " " "a   b c"
      The variable var should equal c
    End
  End

  Describe 'shellspec_is()'
    Describe 'number'
      It 'succeeds with a numeric value'
        When call shellspec_is number 123
        The status should be success
      End

      It 'fails with a not numeric value'
        When call shellspec_is number abc
        The status should be failure
      End

      It 'fails with a zero length string'
        When call shellspec_is number ''
        The status should be failure
      End

      It 'fails with a empty'
        When call shellspec_is number
        The status should be failure
      End
    End

    Describe 'funcname'
      It 'succeeds with valid function name foo_bar'
        When call shellspec_is funcname foo_bar
        The status should be success
      End

      It 'succeeds with valid function name foo123'
        When call shellspec_is funcname foo123
        The status should be success
      End

      It 'fails with invalid function name'
        When call shellspec_is funcname foo+bar
        The status should be failure
      End

      It 'fails with start with number'
        When call shellspec_is funcname 0foo_bar
        The status should be failure
      End

      It 'fails with a zero length string'
        When call shellspec_is funcname ''
        The status should be failure
      End

      It 'fails with a empty'
        When call shellspec_is funcname
        The status should be failure
      End
    End

    It 'raise error with invalid type'
      When invoke shellspec_is invalid-type
      The error should be present
      The status should be failure
    End
  End

  Describe 'shellspec_capture()'
    Context 'when function outputs "ok"'
      func() { %- "ok"; }
      It 'captures "ok"'
        When call shellspec_capture var func
        The variable var should equal ok
      End
    End

    Context 'when function outputs "ok<LF>"'
      func() { %= "ok"; }
      It 'captures "ok<LF>"'
        When call shellspec_capture var func
        The variable var should equal "ok${LF}"
      End
    End

    Context 'when function return false'
      func() { false; }
      It 'can not capture'
        When call shellspec_capture var func
        The variable var should be undefined
      End
    End
  End
End
