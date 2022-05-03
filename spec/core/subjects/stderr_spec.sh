# shellcheck shell=sh disable=SC2016,SC2286,SC2287,SC2288

Describe "core/subjects/stderr.sh"
  mock() {
    unset SHELLSPEC_STDERR ||:
    shellspec_output() { shellspec_puts "$1" >&2; }
    shellspec_readfile() { subject "$@"; }
  }
  BeforeRun mock
  preserve() { %preserve SHELLSPEC_META:META SHELLSPEC_SUBJECT:SUBJECT; }
  AfterRun preserve

  Describe "stderr subject"
    Example 'example'
      foo() { echo "foo" >&2; }
      When call foo
      The stderr should equal "foo"
      The error should equal "foo" # alias for stderr
    End

    It 'uses stderr as subject when stderr is defined'
      subject() { eval "$1=test\${SHELLSPEC_LF}"; }
      When run shellspec_subject_stderr _null_modifier_
      The variable SUBJECT should equal 'test'
      The variable META should eq 'text'
    End

    It 'uses undefined as subject when stderr is undefined'
      subject() { unset "$1" ||:; }
      When run shellspec_subject_stderr _null_modifier_
      The variable SUBJECT should be undefined
      The variable META should eq 'text'
    End

    It 'outputs an error if the next word is missing'
      subject() { eval "$1=test\${SHELLSPEC_LF}"; }
      When run shellspec_subject_stderr
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
      The variable META should eq 'text'
    End
  End

  Describe "entire stderr subject"
    Example 'example'
      foo() { echo "foo" >&2; }
      When call foo
      The entire stderr should equal "foo${SHELLSPEC_LF}"
      The entire error should equal "foo${SHELLSPEC_LF}"
    End

    It 'uses stderr including last LF as subject when stderr is defined'
      subject() { eval "$1=test\${SHELLSPEC_LF}"; }
      When run shellspec_subject_entire_stderr _null_modifier_
      The variable SUBJECT should equal "test${SHELLSPEC_LF}"
      The variable META should eq 'text'
    End

    It 'uses undefined as subject when stderr is undefined'
      subject() { unset "$1" ||:; }
      When run shellspec_subject_entire_stderr _null_modifier_
      The variable SUBJECT should be undefined
      The variable META should eq 'text'
    End

    It 'outputs an error if the next word is missing'
      subject() { eval "$1=test\${SHELLSPEC_LF}"; }
      When run shellspec_subject_entire_stderr
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
      The variable META should eq 'text'
    End
  End
End
