#shellcheck shell=sh

Describe "core/matchers/eq.sh"
  Describe 'equal matcher'
    Example 'example'
      The value "test" should equal "test"
      The value "test" should eq "test" # alias for equal
      The value "test" should not equal "TEST"
      The value "test" should not eq "TEST" # alias for equal
    End

    Example 'matches subject'
      Set SHELLSPEC_SUBJECT="foo bar"
      When invoke matcher equal "foo bar"
      The status should be success
    End

    Example 'not matches subject'
      Set SHELLSPEC_SUBJECT="foo bar"
      When invoke matcher equal "foo"
      The status should be failure
    End

    Example 'not matches undefined subject'
      Unset SHELLSPEC_SUBJECT
      When invoke matcher equal ""
      The status should be failure
    End

    Example 'output error if parameters is missing'
      When invoke matcher equal
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End

    Example 'output error if parameters count is invalid'
      When invoke matcher equal "foo" "bar"
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End
End
