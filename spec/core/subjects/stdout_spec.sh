#shellcheck shell=sh

Describe "core/subjects/stdout.sh"
  mock() {
    unset SHELLSPEC_STDOUT ||:
    shellspec_output() { shellspec_puts "$1" >&2; }
    shellspec_readfile() { subject "$@"; }
  }
  BeforeRun mock
  preserve() { %preserve SHELLSPEC_META:META SHELLSPEC_SUBJECT:SUBJECT; }
  AfterRun preserve

  Describe "stdout subject"
    Example 'example'
      foo() { echo "foo"; }
      When call foo
      The stdout should equal "foo"
      The output should equal "foo" # alias for stdout
    End

    It 'uses stdout as subject when stdout is defined'
      subject() { eval "$1=test\${SHELLSPEC_LF}"; }
      When run shellspec_subject_stdout _null_modifier_
      The variable SUBJECT should equal 'test'
      The variable META should eq 'text'
    End

    It 'uses undefined as subject when stdout is undefined'
      subject() { unset "$1" ||:; }
      When run shellspec_subject_stdout _null_modifier_
      The variable SUBJECT should be undefined
      The variable META should eq 'text'
    End

    It 'outputs an error if the next word is missing'
      subject() { eval "$1=test\${SHELLSPEC_LF}"; }
      When run shellspec_subject_stdout
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
      The variable META should eq 'text'
    End
  End

  Describe "entire stdout subject"
    Example 'example'
      foo() { echo "foo"; }
      When call foo
      The entire stdout should equal "foo${SHELLSPEC_LF}"
      The entire output should equal "foo${SHELLSPEC_LF}"
    End

    It 'uses stdout including last LF as subject when stdout is defined'
      subject() { eval "$1=test\${SHELLSPEC_LF}"; }
      When run shellspec_subject_entire_stdout _null_modifier_
      The variable SUBJECT should equal "test${SHELLSPEC_LF}"
      The variable META should eq 'text'
    End

    It 'uses undefined as subject when stdout is undefined'
      subject() { unset "$1" ||:; }
      When run shellspec_subject_entire_stdout _null_modifier_
      The variable SUBJECT should be undefined
      The variable META should eq 'text'
    End

    It 'outputs an error if the next word is missing'
      subject() { eval "$1=test\${SHELLSPEC_LF}"; }
      When run shellspec_subject_entire_stdout
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
      The variable META should eq 'text'
    End
  End
End
