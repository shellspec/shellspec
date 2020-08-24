#shellcheck shell=sh

Describe "core/subjects/stdout.sh"
  BeforeRun set_stdout subject_mock

  Describe "stdout subject"
    Example 'example'
      foo() { echo "foo"; }
      When call foo
      The stdout should equal "foo"
      The output should equal "foo" # alias for stdout
    End

    It "uses stdout as subject when stdout is defined"
      stdout() { echo "test"; }
      preserve() { %preserve SHELLSPEC_META:META; }
      AfterRun preserve

      When run shellspec_subject_stdout _modifier_
      The entire stdout should equal 'test'
      The variable META should eq 'text'
    End

    It "uses undefined as subject when stdout is undefined"
      stdout() { false; }
      When run shellspec_subject_stdout _modifier_
      The status should be failure
    End

    It 'outputs error if next word is missing'
      stdout() { echo "test"; }
      When run shellspec_subject_stdout
      The entire stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End

  Describe "entire stdout subject"
    Example 'example'
      foo() { echo "foo"; }
      When call foo
      The entire stdout should equal "foo${IFS%?}"
      The entire output should equal "foo${IFS%?}"
    End

    It "uses stdout including last LF as subject when stdout is defined"
      stdout() { echo "test"; }
      preserve() { %preserve SHELLSPEC_META:META; }
      AfterRun preserve

      When run shellspec_subject_entire_stdout _modifier_
      The entire stdout should equal "test${IFS%?}"
      The variable META should eq 'text'
    End

    It "uses undefined as subject when stdout is undefined"
      stdout() { false; }
      When run shellspec_subject_entire_stdout _modifier_
      The status should be failure
    End

    It 'output error if next word is missing'
      stdout() { echo "test"; }
      When run shellspec_subject_entire_stdout
      The entire stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
