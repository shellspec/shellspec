#shellcheck shell=sh

Describe "core/matchers/satisfy.sh"
  Before set_subject intercept_shellspec_matcher
  subject() { false; }

  Describe 'satisfy matcher'
    greater_than() { [ "$SHELLSPEC_SUBJECT" -gt "$1" ]; }

    Example 'example'
      The value 10 should satisfy greater_than 5
      The value 10 should not satisfy greater_than 20
    End

    Context 'when subject is 10'
      subject() { %- 10; }

      It 'satisfies greater than 5'
        When invoke shellspec_matcher satisfy greater_than 5
        The status should be success
      End

      It 'does not satisfies greater than 20'
        When invoke shellspec_matcher satisfy greater_than 20
        The status should be failure
      End
    End

    It 'outputs error if parameters is missing'
      When invoke shellspec_matcher satisfy
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End
End
