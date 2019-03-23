#shellcheck shell=sh

Describe "core/modifiers/lines.sh"
  Before set_subject intercept_shellspec_modifier
  subject() { false; }

  Describe "lines modifier"
    get_text() {
      echo foo
      echo bar
      echo baz
    }
    Example 'example'
      When call get_text
      The lines of stdout should equal 3
    End

    Context 'when subject is "foo<LF>bar<LF>" (without last LF)'
      subject() { shellspec_puts "foo${LF}bar${LF}"; }
      It 'counts as 2 lines'
        When invoke shellspec_modifier lines _modifier_
        The stdout should equal 2
      End
    End

    Context 'when subject is "foo<LF>bar" (without last LF)'
      subject() { shellspec_puts "foo${LF}bar"; }
      It 'counts as 2 lines'
        When invoke shellspec_modifier lines _modifier_
        The stdout should equal 2
      End
    End

    Context 'when subject is "foo<LF>bar<LF><LF>"'
      subject() { shellspec_puts "foo${LF}bar${LF}${LF}"; }
      It 'counts as 3 lines'
        When invoke shellspec_modifier lines _modifier_
        The stdout should equal 3
      End
    End

    Context 'when subject is empty string'
      subject() { shellspec_puts; }
      It 'counts as 0 lines'
        When invoke shellspec_modifier lines _modifier_
        The stdout should equal 0
      End
    End

    Context 'when subject is undefined'
      subject() { false; }
      It 'can not counts lines'
        When invoke shellspec_modifier lines _modifier_
        The status should be failure
      End
    End

    It 'outputs error if next word is missing'
      When invoke shellspec_modifier lines
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
