#shellcheck shell=sh

Describe "core/matchers/eq.sh"
  BeforeRun set_subject matcher_mock

  Describe 'equal matcher'
    Example 'example'
      The value "test" should equal "test"
      The value "test" should eq "test" # alias for equal
      The value "test" should not equal "TEST"
      The value "test" should not eq "TEST" # alias for equal
    End

    It 'matches same string'
      subject() { %- "foo bar"; }
      When run shellspec_matcher_equal "foo bar"
      The status should be success
    End

    It 'does not match different string'
      subject() { %- "foo bar"; }
      When run shellspec_matcher_equal "foo"
      The status should be failure
    End

    It 'does not match undefined'
      subject() { false; }
      When run shellspec_matcher_equal ""
      The status should be failure
    End

    It "matches with '!'"
      subject() { %- "!"; }
      When run shellspec_matcher_equal "!"
      The status should be success
    End

    It 'outputs error if parameters is missing'
      subject() { %- "foo bar"; }
      When run shellspec_matcher_equal
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End

    It 'outputs error if parameters count is invalid'
      subject() { %- "foo"; }
      When run shellspec_matcher_equal "foo" "bar"
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End
  End
End
