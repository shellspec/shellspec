#shellcheck shell=sh

Describe "core/subjects/fd.sh"
  BeforeRun 'set_fd 5' subject_mock

  Describe "fd subject"
    Describe "example"
      UseFD 5
      Example 'example'
        foo() { echo "foo" >&5; }
        When call foo
        The fd 5 should equal "foo"
      End

      Skip "Assignment of file descriptors to variables is not available" if [ ! "$SHELLSPEC_FDVAR_AVAILABLE" ]

      UseFD FD
      Example 'example'
        # shellcheck disable=SC2039
        foo() { echo "foo" >&"$FD"; }
        When call foo
        The fd FD should equal "foo"
      End
    End

    It 'uses the fd as subject when the fd exists'
      fd5() { echo "test"; }
      When run shellspec_subject_fd 5 _modifier_
      The entire stdout should equal 'test'
    End

    It 'uses undefined as subject when the fd not exists'
      fd5() { false; }
      When run shellspec_subject_fd 5 _modifier_
      The status should be failure
    End

    It "sets SHELLSPEC_META to text"
      fd5() { :; }
      preserve() { %preserve SHELLSPEC_META:META; }
      AfterRun preserve

      When run shellspec_subject_fd 5 _modifier_
      The variable META should eq 'text'
    End

    It 'outputs an error if the file descriptor is missing'
      fd5() { echo "test"; }
      When run shellspec_subject_fd
      The entire stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End

    It 'outputs an error if the next word is missing'
      fd5() { echo "test"; }
      When run shellspec_subject_fd 5
      The entire stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End

  Describe "entire fd subject"
    Describe "example"
      UseFD 5
      Example 'example'
        foo() { echo "foo" >&5; }
        When call foo
        The entire fd 5 should equal "foo${SHELLSPEC_LF}"
      End
    End

    It 'uses the fd including last LF as subject when the fd exists'
      fd5() { echo "test"; }
      When run shellspec_subject_entire_fd 5 _modifier_
      The entire stdout should equal "test${SHELLSPEC_LF}"
    End

    It 'uses undefined as subject when the fd not exits'
      fd5() { false; }
      When run shellspec_subject_entire_fd 5 _modifier_
      The status should be failure
    End

    It "sets SHELLSPEC_META to text"
      fd5() { :; }
      preserve() { %preserve SHELLSPEC_META:META; }
      AfterRun preserve

      When run shellspec_subject_entire_fd 5 _modifier_
      The variable META should eq 'text'
    End

    It 'outputs an error if the file descriptor is missing'
      fd5() { echo "test"; }
      When run shellspec_subject_entire_fd
      The entire stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End

    It 'outputs an error if the next word is missing'
      fd5() { echo "test"; }
      When run shellspec_subject_entire_fd 5
      The entire stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
