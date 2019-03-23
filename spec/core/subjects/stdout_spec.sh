#shellcheck shell=sh

Describe "core/subjects/stdout.sh"
  Before set_stdout intercept_shellspec_subject
  stdout() { false; }

  Describe "stdout subject"
    Example 'example'
      func() { echo "foo"; }
      When call func
      The stdout should equal "foo"
      The output should equal "foo" # alias for stdout
    End

    Context 'when stdout is defined'
      stdout() { shellspec_puts "test${LF}"; }
      It "uses stdout as subject"
        When invoke shellspec_subject stdout _modifier_
        The entire stdout should equal 'test'
      End
    End

    Context 'when stdout is undefined'
      stdout() { false; }
      It "uses undefined as subject"
        When invoke shellspec_subject stdout _modifier_
        The status should be failure
      End
    End

    It 'outputs error if next word is missing'
      When invoke shellspec_subject stdout
      The entire stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End

  Describe "entire stdout subject"
    Example 'example'
      func() { echo "foo"; }
      When call func
      The entire stdout should equal "foo${LF}"
      The entire output should equal "foo${LF}" # alias for entire stdout
    End

    Context 'when stdout is defined'
      stdout() { shellspec_puts "test${LF}"; }
      It "uses stdout including last LF as subject"
        When invoke shellspec_subject entire stdout _modifier_
        The entire stdout should equal "test${LF}"
      End
    End

    Context 'when stdout is undefined'
      stdout() { false; }
      It "uses undefined as subject"
        When invoke shellspec_subject entire stdout _modifier_
        The status should be failure
      End
    End

    It 'output error if next word is missing'
      When invoke shellspec_subject entire stdout
      The entire stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
