#shellcheck shell=sh

% FILE: "$SHELLSPEC_SPECDIR/fixture/end-with-multiple-lf.txt"

Describe "core/modifiers/contents.sh"
  Before set_subject set_contents intercept_shellspec_modifier
  subject() { false; }

  Describe "contents modifier"
    set_contents() { contents="a"; }

    Example 'example'
      The contents of file "$FILE" should equal "$contents"
      The contents of the file "$FILE" should equal "$contents"
      The file "$FILE" contents should equal "$contents"
    End

    Context 'when file exists'
      subject() { shellspec_puts "$FILE"; }
      It 'reads the contents of the file'
        When invoke shellspec_modifier contents _modifier_
        The entire stdout should equal "$contents"
      End
    End

    Context 'when file not exists'
      subject() { shellspec_puts "$FILE.not-exists"; }
      It 'cannot reads the contents of the file'
        When invoke shellspec_modifier contents _modifier_
        The status should be failure
      End
    End

    Context 'when file not specified'
      subject() { false; }
      It 'cannot reads the contents of the file'
        When invoke shellspec_modifier contents _modifier_
        The status should be failure
      End
    End

    It 'outputs error if next modifier is missing'
      When invoke shellspec_modifier contents
      The entire stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End

  Describe "entire contents modifier"
    set_contents() { contents="a${LF}${LF}"; }

    Example 'example'
      The entire contents of file "$FILE" should equal "$contents"
      The entire contents of the file "$FILE" should equal "$contents"
      The file "$FILE" entire contents should equal "$contents"
    End

    Context 'when file exists'
      subject() { shellspec_puts "$FILE"; }
      It 'reads the entire contents of the file'
        When invoke shellspec_modifier entire contents _modifier_
        The entire stdout should equal "$contents"
      End
    End

    Context 'when file not exists'
      subject() { shellspec_puts "$FILE.not-exists"; }
      It 'can not reads the entire contents of the file'
        When invoke shellspec_modifier entire contents _modifier_
        The status should be failure
      End
    End

    Context 'when file not specified'
      subject() { false; }
      It 'can not read the entire contents of the file'
        When invoke shellspec_modifier entire contents _modifier_
        The status should be failure
      End
    End

    It 'outputs error if next modifier is missing'
      When invoke shellspec_modifier entire contents
      The entire stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
