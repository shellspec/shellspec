#shellcheck shell=sh

Describe "core/matchers/end_with.sh"
  Before set_subject intercept_shellspec_matcher
  subject() { false; }

  Describe "end with matcher"
    Example 'example'
      The value "foobarbaz" should end with "baz"
      The value "foobarbaz" should not end with "BAZ"
    End

    Context 'when subject is abcdef'
      subject() { shellspec_puts abcdef; }

      Example 'should end with "def"'
        When invoke shellspec_matcher end with "def"
        The status should be success
      End

      Example 'should not end with "DEF"'
        When invoke shellspec_matcher end with "DEF"
        The status should be failure
      End
    End

    Example 'outputs error if parameters is missing'
      When invoke shellspec_matcher end with
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End

    Example 'outputs error if parameters count is invalid'
      When invoke shellspec_matcher end with "foo" "bar"
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End
End
