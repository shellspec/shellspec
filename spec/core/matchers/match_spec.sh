#shellcheck shell=sh

Describe "core/matchers/match.sh"
  Before set_subject intercept_shellspec_matcher
  subject() { false; }

  Describe 'match matcher'
    Example 'example'
      The value "foobarbaz" should match "foo*"
      The value "foobarbaz" should not match "FOO*"
    End

    Context 'when subject is foobarbaz'
      subject() { shellspec_puts foobarbaz; }

      Example 'should match "foo*"'
        When invoke shellspec_matcher match "foo*"
        The status should be success
      End

      Example 'should match "FOO*"'
        When invoke shellspec_matcher match "FOO*"
        The status should be failure
      End
    End

    Context 'when subject is undefined'
      subject() { false; }
      Example 'should not match "*"'
        When invoke shellspec_matcher match "*"
        The status should be failure
      End
    End

    Example 'outputs error if parameters is missing'
      When invoke shellspec_matcher match
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End

    Example 'outputs error if parameters count is invalid'
      When invoke shellspec_matcher match "foo" "bar"
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End
End
