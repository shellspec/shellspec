#shellcheck shell=sh

Describe "core/modifiers/contents.sh"
  readonly file="$SHELLSPEC_SPECDIR/fixture/end-with-multiple-lf.txt"

  Before set_subject intercept_shellspec_modifier
  subject() { false; }

  Describe "contents modifier"
    readonly contents="a"

    Example 'example'
      The contents of file "$file" should equal "$contents"
      The contents of the file "$file" should equal "$contents"
      The file "$file" contents should equal "$contents"
      The the file "$file" contents should equal "$contents"
    End

    Context 'when file exists'
      subject() { shellspec_puts "$file"; }
      Example 'reads the contents of the file'
        When invoke shellspec_modifier contents _modifier_
        The entire stdout should equal "$contents"
      End
    End

    Context 'when file not exists'
      subject() { shellspec_puts "$file.not-exists"; }
      Example 'cannot reads the contents of the file'
        When invoke shellspec_modifier contents _modifier_
        The status should be failure
      End
    End

    Context 'when file not specified'
      subject() { false; }
      Example 'cannot reads the contents of the file'
        When invoke shellspec_modifier contents _modifier_
        The status should be failure
      End
    End

    Example 'outputs error if next modifier is missing'
      When invoke shellspec_modifier contents
      The entire stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End

  Describe "entire contents modifier"
    readonly contents="a${LF}${LF}"

    Example 'example'
      The entire contents of file "$file" should equal "$contents"
      The entire contents of the file "$file" should equal "$contents"
      The file "$file" entire contents should equal "$contents"
      The the file "$file" entire contents should equal "$contents"
    End

    Context 'when file exists'
      subject() { shellspec_puts "$file"; }
      Example 'reads the entire contents of the file'
        When invoke shellspec_modifier entire contents _modifier_
        The entire stdout should equal "$contents"
      End
    End

    Context 'when file not exists'
      subject() { shellspec_puts "$file.not-exists"; }
      Example 'cannot reads the entire contents of the file'
        When invoke shellspec_modifier entire contents _modifier_
        The status should be failure
      End
    End

    Context 'when file not specified'
      subject() { false; }
      Example 'cannot read the entire contents of the file'
        When invoke shellspec_modifier entire contents _modifier_
        The status should be failure
      End
    End

    Example 'outputs error if next modifier is missing'
      When invoke shellspec_modifier entire contents
      The entire stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
