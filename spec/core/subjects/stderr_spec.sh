#shellcheck shell=sh

Describe "core/subjects/stderr.sh"
  Before set_stderr intercept_shellspec_subject
  stderr() { false; }

  Describe "stderr subject"
    Example 'example'
      func() { echo "foo" >&2; }
      When call func
      The stderr should equal "foo"
      The error should equal "foo" # alias for stderr
    End

    Context 'when stderr is defined'
      stderr() { shellspec_puts "test${LF}"; }
      It 'uses stderr as subject'
        When invoke shellspec_subject stderr _modifier_
        The entire stdout should equal 'test'
      End
    End

    Context 'when stderr is undefined'
      stderr() { false; }
      It 'uses undefined as subject'
        When invoke shellspec_subject stderr _modifier_
        The status should be failure
      End
    End

    It 'outputs error if next word is missing'
      When invoke shellspec_subject stderr
      The entire stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End

  Describe "entire stderr subject"
    Example 'example'
      func() { echo "foo" >&2; }
      When call func
      The entire stderr should equal "foo${LF}"
      The entire error should equal "foo${LF}"
    End

    Context 'when stderr is defined'
      stderr() { shellspec_puts "test${LF}"; }
      It 'uses stderr including last LF as subject'
        When invoke shellspec_subject entire stderr _modifier_
        The entire stdout should equal "test${LF}"
      End
    End

    Context 'when stderr is undefined'
      stderr() { false; }
      It 'uses undefined as subject'
        When invoke shellspec_subject entire stderr _modifier_
        The status should be failure
      End
    End

    It 'outputs error if next word is missing'
      When invoke shellspec_subject entire stderr
      The entire stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
