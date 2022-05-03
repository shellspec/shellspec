# shellcheck shell=sh disable=SC2016,SC2286,SC2287,SC2288

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
      echo_stderr() { echo stderr >&2; }
      subject() { %- 10; }
      preserve() { %preserve SHELLSPEC_SW_WARNED:WARNED; }
      AfterRun preserve

      When run shellspec_matcher_satisfy echo_stderr
      The stderr should equal SATISFY_WARN
      The variable WARNED should eq 1
    End

    It 'outputs error if invalid function name specified'
      subject() { %- 10; }
      preserve() { %preserve SHELLSPEC_SW_SYNTAX_ERROR:SYNTAX_ERROR; }
      AfterRun preserve

      When run shellspec_matcher_satisfy greater-than 20
      The stderr should equal SYNTAX_ERROR
      The variable SYNTAX_ERROR should eq 1
    End

    It 'outputs error if parameters is missing'
      subject() { %- 10; }
      When run shellspec_matcher_satisfy
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End
  End
End
