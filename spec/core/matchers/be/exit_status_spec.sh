#shellcheck shell=sh

Describe "core/matchers/be/exit_status.sh"
  Before set_subject
  subject() { false; }

  Describe 'be success matcher'
    Example 'example'
      The value 0 should be success
      The value 1 should not be success
    End

    Context 'when subject is 0'
      subject() { shellspec_puts 0; }
      Example 'should matches'
        When invoke spy_shellspec_matcher be success
        The status should be success
      End
    End

    Context 'when subject is 1'
      subject() { shellspec_puts 1; }
      Example 'should not matches'
        When invoke spy_shellspec_matcher be success
        The status should be failure
      End
    End

    Context 'when subject is non number values'
      subject() { shellspec_puts "a"; }
      Example 'should not matches'
        When invoke spy_shellspec_matcher be success
        The status should be failure
      End
    End

    Context 'when subject is zero length string'
      subject() { shellspec_puts; }
      Example 'should not matches'
        When invoke spy_shellspec_matcher be success
        The status should be failure
      End
    End

    Context 'when subject is undefined'
      subject() { false; }
      Example 'should not matches'
        When invoke spy_shellspec_matcher be success
        The status should be failure
      End
    End

    Example 'outputs error if parameters count is invalid'
      When invoke spy_shellspec_matcher be success foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'be failure matcher'
    Example 'example'
      The value 1 should be failure
      The value 0 should not be failure
    End

    Context 'when subject is 1'
      subject() { shellspec_puts 1; }
      Example 'should matches'
        When invoke spy_shellspec_matcher be failure
        The status should be success
      End
    End

    Context 'when subject is 0'
      subject() { shellspec_puts 0; }
      Example 'should not matches'
        When invoke spy_shellspec_matcher be failure
        The status should be failure
      End
    End

    Context 'when subject is -1'
      subject() { shellspec_puts -1; }
      Example 'should not matches'
        When invoke spy_shellspec_matcher be failure
        The status should be failure
      End
    End

    Context 'when subject is 255'
      subject() { shellspec_puts 255; }
      Example 'should matches'
        When invoke spy_shellspec_matcher be failure
        The status should be success
      End
    End

    Context 'when subject is 256'
      subject() { shellspec_puts 256; }
      Example 'should not matches'
        When invoke spy_shellspec_matcher be failure
        The status should be failure
      End
    End

    Context 'when subject is "a" (non numeric values)'
      subject() { shellspec_puts a; }
      Example 'should not matches'
        When invoke spy_shellspec_matcher be failure
        The status should be failure
      End
    End

    Context 'when subject is zero length string'
      subject() { shellspec_puts; }
      Example 'should not matches'
        When invoke spy_shellspec_matcher be failure
        The status should be failure
      End
    End

    Context 'when subject is undefined'
      subject() { false; }
      Example 'should not matches'
        When invoke spy_shellspec_matcher be failure
        The status should be failure
      End
    End

    Example 'outputs error if parameters count is invalid'
      When invoke spy_shellspec_matcher be failure foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End
End