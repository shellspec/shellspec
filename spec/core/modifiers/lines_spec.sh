#shellcheck shell=sh

Describe "core/modifiers/lines.sh"
  Describe "lines modifier"
    Before set_subject
    subject() { false; }

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
      Example 'it number of lines should equal 2'
        When invoke modifier lines _modifier_
        The stdout should equal 2
      End
    End

    Context 'when subject is "foo<LF>bar<LF>"'
      subject() { shellspec_puts "foo${LF}bar${LF}"; }
      Example 'it number of lines should equal 2'
        When invoke modifier lines _modifier_
        The stdout should equal 2
      End
    End

    Context 'when subject is "foo<LF>bar<LF><LF>"'
      subject() { shellspec_puts "foo${LF}bar${LF}${LF}"; }
      Example 'it number of lines should equal 3'
        When invoke modifier lines _modifier_
        The stdout should equal 3
      End
    End

    Context 'when subject is empty string'
      subject() { shellspec_puts; }
      Example 'get number of lines of empty string'
        When invoke modifier lines _modifier_
        The stdout should equal 0
      End
    End
  End
End
