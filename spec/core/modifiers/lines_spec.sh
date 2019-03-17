#shellcheck shell=sh

Describe "core/modifiers/lines.sh"
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

    Example 'get number of lines of subject'
      Set SHELLSPEC_SUBJECT="foo${SHELLSPEC_LF}bar"
      When invoke modifier lines _modifier_
      The stdout should equal 2
    End

    Example 'get number of lines of subject that end with newline'
      Set SHELLSPEC_SUBJECT="foo${SHELLSPEC_LF}bar${SHELLSPEC_LF}"
      When invoke modifier lines _modifier_
      The stdout should equal 2
    End

    Example 'get number of lines of empty string'
      Set SHELLSPEC_SUBJECT=""
      When invoke modifier lines _modifier_
      The stdout should equal 0
    End
  End
End
