#shellcheck shell=sh

Describe "core/matchers/satisfy.sh"
  BeforeRun set_subject matcher_mock

  Describe 'satisfy matcher'
    greater_than() { [ "${greater_than:?}" -gt "$1" ]; }

    Example 'example'
      The value 10 should satisfy greater_than 5
      The value 10 should not satisfy greater_than 20
    End

    It 'calls function with subject and arguments'
      subject() { %- 10; }
      When run shellspec_matcher_satisfy greater_than 5
      The status should be success
    End

    It 'calls function with undefined subject and arguments'
      subject() { false; }
      When run shellspec_matcher_satisfy greater_than 5
      The stderr should be present
      The status should be failure
    End

    It 'should be failure when satisfies condition fails'
      subject() { %- 10; }
      When run shellspec_matcher_satisfy greater_than 20
      The status should be failure
    End

    It 'outputs SATISFY_WARN if satisfy function echo to stdout'
      echo_stdout() { echo stdout; }
      subject() { %- 10; }
      When run shellspec_matcher_satisfy echo_stdout
      The stderr should equal SATISFY_WARN
    End

    It 'outputs SATISFY_ERROR if satisfy function echo to stdout'
      echo_stderr() { echo stderr >&2; }
      subject() { %- 10; }
      When run shellspec_matcher_satisfy echo_stderr
      The stderr should equal SATISFY_ERROR
    End

    It 'outputs error if invalid function name specified'
      subject() { %- 10; }
      When run shellspec_matcher_satisfy greater-than 20
      The stderr should equal SYNTAX_ERROR
    End

    It 'outputs error if parameters is missing'
      subject() { %- 10; }
      When run shellspec_matcher_satisfy
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End
  End
End
