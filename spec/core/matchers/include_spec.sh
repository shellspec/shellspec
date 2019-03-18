#shellcheck shell=sh

Describe "core/matchers/include.sh"
  Before set_subject
  subject() { false; }

  Describe 'include matcher'
    Example 'example'
      The value "foobarbaz" should include "bar"
      The value "foobarbaz" should not include "BAR"
    End

    Context 'when subject is foo<LF>bar<LF>baz<LF>'
      subject() { shellspec_puts "foo${LF}bar${LF}baz${LF}"; }
      Example 'it should include bar'
        When invoke spy_shellspec_matcher include "bar"
        The status should be success
      End
    End

    Context 'when subject is foo<LF>BAR<LF>baz<LF>'
      subject() { shellspec_puts "foo${LF}BAR${LF}baz${LF}"; }
      Example 'it should not include bar'
        When invoke spy_shellspec_matcher include "bar"
        The status should be failure
      End
    End

    Example 'output error if parameters is missing'
      When invoke spy_shellspec_matcher include
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End

    Example 'output error if parameters count is invalid'
      When invoke spy_shellspec_matcher include "foo" "bar"
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End
End
