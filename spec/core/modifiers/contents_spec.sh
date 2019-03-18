#shellcheck shell=sh

Describe "core/modifiers/contents.sh"
  Before setup set_contents set_subject
  setup() { file="$SHELLSPEC_SPECDIR/fixture/end-with-multiple-lf.txt"; }
  subject() { false; }

  Describe "contents modifier"
    set_contents() { contents="a"; }

    Example 'example'
      The contents of file "$file" should equal "$contents"
      The contents of the file "$file" should equal "$contents"
      The file "$file" contents should equal "$contents"
      The the file "$file" contents should equal "$contents"
    End

    Context 'when exist file'
      subject() { shellspec_puts "$file"; }
      Example 'read contents of file'
        When invoke modifier contents _modifier_
        The entire stdout should equal "$contents"
      End
    End

    Context 'when not exist file'
      subject() { shellspec_puts "$file.not-exists"; }
      Example 'can not read contents of file'
        When invoke modifier contents _modifier_
        The status should be failure
      End
    End

    Context 'when file not specified'
      subject() { false; }
      Example 'can not read contents of file'
        When invoke modifier contents _modifier_
        The status should be failure
      End
    End

    Example 'output error if next modifier is missing'
      When invoke modifier contents
      The entire stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End

  Describe "entire contents modifier"
    set_contents() { contents="a${LF}${LF}"; }

    Example 'example'
      The entire contents of file "$file" should equal "$contents"
      The entire contents of the file "$file" should equal "$contents"
      The file "$file" entire contents should equal "$contents"
      The the file "$file" entire contents should equal "$contents"
    End

    Context 'when exist file'
      subject() { shellspec_puts "$file"; }
      Example 'read entire contents of file'
        When invoke modifier entire contents _modifier_
        The entire stdout should equal "$contents"
      End
    End

    Context 'when not exist file'
      subject() { shellspec_puts "$file.not-exists"; }
      Example 'can not read contents of file'
        When invoke modifier entire contents _modifier_
        The status should be failure
      End
    End

    Context 'when file not specified'
      subject() { false; }
      Example 'can not read contents of file'
        When invoke modifier entire contents _modifier_
        The status should be failure
      End
    End

    Example 'output error if next modifier is missing'
      When invoke modifier entire contents
      The entire stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
