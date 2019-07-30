#shellcheck shell=sh

Describe "core/matchers/satisfy.sh"
  BeforeRun set_subject matcher_mock

  Describe 'satisfy matcher'
    greater_than() { [ "$SHELLSPEC_SUBJECT" -gt "$1" ]; }

    Example 'example'
      The value 10 should satisfy greater_than 5
      The value 10 should not satisfy greater_than 20
    End

    It 'matches when satisfies condition'
      subject() { %- 10; }
      When run shellspec_matcher_satisfy greater_than 5
      The status should be success
    End

    It 'does not match when not satisfies condition'
      subject() { %- 10; }
      When run shellspec_matcher_satisfy greater_than 20
      The status should be failure
    End

    It 'outputs error if parameters is missing'
      subject() { %- 10; }
      When run shellspec_matcher_satisfy
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End
  End
End
