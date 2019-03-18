#shellcheck shell=sh

Describe "core/matchers/be/variable.sh"
  Before set_subject
  subject() { false; }

  Describe 'be defined matcher'
    Before 'shellspec_set var1=1' 'shellspec_unset var2'
    Example 'example'
      The variable var1 should be defined
      The variable var2 should not be defined
    End

    Context 'when subject is empty string'
      subject() { shellspec_puts; }
      Example 'it should be success'
        When invoke spy_shellspec_matcher be defined
        The status should be success
      End
    End

    Context 'when subject is undefined'
      subject() { false; }
      Example 'it should be failure'
        When invoke spy_shellspec_matcher be defined
        The status should be failure
      End
    End

    Example 'output error if parameters count is invalid'
      When invoke spy_shellspec_matcher be defined foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be undefined matcher'
    Before 'shellspec_unset var1' 'shellspec_set var2=1'
    Example 'example'
      The variable var1 should be undefined
      The variable var2 should not be undefined
    End

    Context 'when subject is undefined'
      subject() { false; }
      Example 'it should be success'
        When invoke spy_shellspec_matcher be undefined
        The status should be success
      End
    End

    Context 'when subject is empty string'
      subject() { shellspec_puts; }
      Example 'it should be failure'
        When invoke spy_shellspec_matcher be undefined
        The status should be failure
      End
    End

    Example 'output error if parameters count is invalid'
      When invoke spy_shellspec_matcher be undefined foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be present matcher'
    Before 'shellspec_set var1="x" var2=""'
    Example 'example'
      The variable var1 should be present
      The variable var2 should not be present
    End

    Context 'when subject is non zero length string'
      subject() { shellspec_puts x; }
      Example 'it should be success'
        When invoke spy_shellspec_matcher be present
        The status should be success
      End
    End

    Context 'when subject is zero length string'
      subject() { shellspec_puts; }
      Example 'it should be failure'
        When invoke spy_shellspec_matcher be present
        The status should be failure
      End
    End

    Context 'when subject is undefind'
      subject() { false; }
      Example 'it should be failure'
        When invoke spy_shellspec_matcher be present
        The status should be failure
      End
    End

    Example 'output error if parameters count is invalid'
      When invoke spy_shellspec_matcher be present foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be blank matcher'
    Before 'shellspec_set var1="" var2="x"'
    Example 'example'
      The variable var1 should be blank
      The variable var2 should not be blank
    End

    Context 'when subject is zero length string'
      subject() { shellspec_puts; }
      Example 'it should be success'
        When invoke spy_shellspec_matcher be blank
        The status should be success
      End
    End

    Context 'when subject is undefind'
      subject() { false; }
      Example 'it should be success'
        When invoke spy_shellspec_matcher be blank
        The status should be success
      End
    End

    Context 'when subject is non zero length string'
      subject() { shellspec_puts x; }
      Example 'it should be failure'
        When invoke spy_shellspec_matcher be blank
        The status should be failure
      End
    End

    Example 'output error if parameters count is invalid'
      When invoke spy_shellspec_matcher be blank foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End
End