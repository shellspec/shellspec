#shellcheck shell=sh

Describe "core/modifiers/result.sh"
  BeforeRun set_subject modifier_mock

  Describe "result modifier"
    foo() { echo ok; true; }

    Example 'example'
      The result of 'foo()' should equal ok
    End

    Describe 'example with stdout, stderr and status'
      foo() { echo stdout; echo stderr >&2; return 123; }
      get_stdout() { echo "$1"; }
      get_stderr() { echo "$2"; }
      get_status() { echo "$3"; }

      It "retrives result of evaluation"
        When call foo
        The result of 'get_stdout()' should equal "stdout"
        The result of 'get_stderr()' should equal "stderr"
        The result of 'get_status()' should equal 123
      End
    End

    It 'gets stdout and stderr when subject is function that returns success'
      subject() { %- "success_with_output"; }
      success_with_output() { echo stdout; true; }
      When run shellspec_modifier_result _modifier_
      The stdout should include stdout
    End

    It 'can not get output when subject is function that returns failure'
      subject() { %- "failure_with_stdout"; }
      failure_with_stdout() { echo stdout; false; }
      When run shellspec_modifier result _modifier_
      The status should be failure
      The stdout should be blank
    End

    It 'returns undefined when subject is undefined'
      subject() { false; }
      When run shellspec_modifier_result _modifier_
      The status should be failure
    End

    It 'outputs RESULT_WARN if outputted something to stderr'
      subject() { %- "success_with_output"; }
      success_with_output() { echo stderr>&2; true; }
      When run shellspec_modifier_result _modifier_
      The stderr should equal RESULT_WARN
      The status should be failure
    End

    It 'outputs error if invalid function name specified'
      subject() { %- "foo -a"; }
      When run shellspec_modifier_result
      The stderr should equal SYNTAX_ERROR
      The status should be failure
    End

    It 'outputs error if next modifier is missing'
      subject() { %- "success_with_stdout"; }
      success_with_stdout() { echo ok; true; }
      When run shellspec_modifier_result
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
