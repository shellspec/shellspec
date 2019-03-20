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

    Example 'example (end with newline)'
      When call get_text
      The lines of entire stdout should equal 3
    End

    Context 'when subject is "foo<LF>bar"'
      subject() { shellspec_puts "foo${LF}bar"; }
      Example 'its number of lines should equal 2'
        When invoke shellspec_modifier lines _modifier_
        The stdout should equal 2
      End
    End

    Context 'when subject is "foo<LF>bar<LF>"'
      subject() { shellspec_puts "foo${LF}bar${LF}"; }
      Example 'its number of lines should equal 2'
        When invoke shellspec_modifier lines _modifier_
        The stdout should equal 2
      End
    End

    Context 'when subject is "foo<LF>bar<LF><LF>"'
      subject() { shellspec_puts "foo${LF}bar${LF}${LF}"; }
      Example 'its number of lines should equal 3'
        When invoke shellspec_modifier lines _modifier_
        The stdout should equal 3
      End
    End

    Context 'when subject is empty string'
      subject() { shellspec_puts; }
      Example 'its number of lines should equal 0'
        When invoke shellspec_modifier lines _modifier_
        The stdout should equal 0
      End
    End

    Context 'when subject is undefined'
      subject() { false; }
      Example 'cannot get number of lines'
        When invoke shellspec_modifier lines _modifier_
        The status should be failure
      End
    End

    Example 'outputs error if next word is missing'
      When invoke shellspec_modifier lines
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
