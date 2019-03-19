#shellcheck shell=sh disable=SC2016

Describe "core/utils.sh"
  Describe 'shellspec_readfile()'
    setup() { file="$SHELLSPEC_SPECDIR/fixture/end-with-multiple-lf.txt"; }
    Before setup

    Example 'read file as is'
      When call shellspec_readfile var "$file"
      The variable var should equal "a${LF}${LF}"
    End
  End

  Describe 'shellspec_get_nth()'
    Example 'fetch nth seperate by ,'
      When call shellspec_get_nth var 3 ',' "a,b,c,d,e"
      The variable var should equal c
    End

    Example 'fetch nth seperate by space'
      When call shellspec_get_nth var 3 " " "a   b c"
      The variable var should equal c
    End
  End

  Describe 'shellspec_is()'
    Describe 'number'
      Example 'succeeds with a numeric value'
        When call shellspec_is number 123
        The exit status should be success
      End

      Example 'fails with a not numeric value'
        When call shellspec_is number abc
        The exit status should be failure
      End

      Example 'fails with a zero length string'
        When call shellspec_is number ''
        The exit status should be failure
      End

      Example 'fails with a empty'
        When call shellspec_is number
        The exit status should be failure
      End
    End

    Describe 'function'
      Example 'succeeds with valid function name foo_bar'
        When call shellspec_is funcname foo_bar
        The exit status should be success
      End

      Example 'succeeds with valid function name foo123'
        When call shellspec_is funcname foo123
        The exit status should be success
      End

      Example 'fails with invalid function name'
        When call shellspec_is funcname foo+bar
        The exit status should be failure
      End

      Example 'fails with start with number'
        When call shellspec_is funcname 0foo_bar
        The exit status should be failure
      End

      Example 'fails with a zero length string'
        When call shellspec_is funcname ''
        The exit status should be failure
      End

      Example 'fails with a empty'
        When call shellspec_is funcname
        The exit status should be failure
      End
    End
  End

  Describe 'shellspec_capture()'
    Context 'func outputs "ok"'
      func() { shellspec_puts ok; }
      Example 'capture ok'
        When call shellspec_capture var func
        The variable var should equal ok
      End
    End

    Context 'func outputs "ok<LF>"'
      func() { echo ok; }
      Example 'capture ok<LF>'
        When call shellspec_capture var func
        The variable var should equal "ok${LF}"
      End
    End

    Context 'func return false'
      func() { false; }
      Example 'variable should be undefined'
        When call shellspec_capture var func
        The variable var should be undefined
      End
    End
  End
End
