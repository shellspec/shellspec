#shellcheck shell=sh

Describe "core/matchers/satisfy.sh"
  Before set_subject
  subject() { false; }

  Describe 'satisfy matcher'
    check() { [ "$SHELLSPEC_SUBJECT" = "$1" ]; }

    Example 'example'
      The value foo should satisfy check foo
      The value foo should not satisfy check bar
    End

    Context 'when subject is foo'
      subject() { shellspec_puts foo; }

      Example 'it should satisfy check foo'
        When invoke spy_shellspec_matcher satisfy check foo
        The status should be success
      End

      Example 'it should satisfy check bar'
        When invoke spy_shellspec_matcher satisfy check bar
        The status should be failure
      End
    End

    Example 'output error if parameters is missing'
      When invoke spy_shellspec_matcher satisfy
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End
End
