#shellcheck shell=sh

Describe "core/matchers/end_with.sh"
  Describe "end with matcher"
    Before set_subject
    subject() { false; }

    Example 'example'
      The value "foobarbaz" should end with "baz"
      The value "foobarbaz" should not end with "BAZ"
    End

    Context 'when subject is abcdef'
      subject() { shellspec_puts abcdef; }

      Example 'it should end with "def"'
        When invoke matcher end with "def"
        The status should be success
      End

      Example 'it should not end with "DEF"'
        When invoke matcher end with "DEF"
        The status should be failure
      End
    End

    Example 'output error if parameters is missing'
      When invoke matcher end with
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End

    Example 'output error if parameters count is invalid'
      When invoke matcher end with "foo" "bar"
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End
End
