#shellcheck shell=sh

Describe "core/matchers/include.sh"
  Before set_subject intercept_shellspec_matcher
  subject() { false; }

  Describe 'include matcher'
    Example 'example'
      The value "foobarbaz" should include "bar"
      The value "foobarbaz" should not include "BAR"
    End

    Context 'when subject is foo<LF>bar<LF>baz<LF>'
      Def subject "foo${LF}bar${LF}baz${LF}"
      It 'matches that include "bar"'
        When invoke shellspec_matcher include "bar"
        The status should be success
      End
    End

    Context 'when subject is foo<LF>BAR<LF>baz<LF>'
      Def subject "foo${LF}BAR${LF}baz${LF}"
      It 'does not matches that include "bar"'
        When invoke shellspec_matcher include "bar"
        The status should be failure
      End
    End

    It 'outputs error if parameters is missing'
      When invoke shellspec_matcher include
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End

    It 'outputs error if parameters count is invalid'
      When invoke shellspec_matcher include "foo" "bar"
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End
End
