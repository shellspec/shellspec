#shellcheck shell=sh

Describe "core/modifiers/contents.sh"
  setup() { file="$SHELLSPEC_SPECDIR/fixture/end-with-multiple-lf.txt"; }
  Before setup contents

  Describe "contents modifier"
    contents() { contents="a"; }

    Example 'example'
      The contents of file "$file" should equal "$contents"
      The contents of the file "$file" should equal "$contents"
      The file "$file" contents should equal "$contents"
      The the file "$file" contents should equal "$contents"
    End

    Example 'read file contents'
      Set SHELLSPEC_SUBJECT="$file"
      When invoke modifier contents _modifier_
      The entire stdout should equal "$contents"
    End

    Example 'can not read not exists file'
      Set SHELLSPEC_SUBJECT="$file.not-exists"
      When invoke modifier contents _modifier_
      The status should be failure
    End

    Example 'can not read file not specified'
      Unset SHELLSPEC_SUBJECT
      When invoke modifier contents _modifier_
      The status should be failure
    End

    Example 'output error if next modifier is missing'
      Set SHELLSPEC_SUBJECT="$file"
      When invoke modifier contents
      The entire stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End

  Describe "entire contents modifier"
    contents() { contents="a${SHELLSPEC_LF}${SHELLSPEC_LF}"; }

    Example 'example'
      The entire contents of file "$file" should equal "$contents"
      The entire contents of the file "$file" should equal "$contents"
      The file "$file" entire contents should equal "$contents"
      The the file "$file" entire contents should equal "$contents"
    End

    Example 'read entire file contents'
      Set SHELLSPEC_SUBJECT="$file"
      When invoke modifier entire contents _modifier_
      The entire stdout should equal "$contents"
    End

    Example 'can not read not exists file'
      Set SHELLSPEC_SUBJECT="$file.not-exists"
      When invoke modifier entire contents _modifier_
      The status should be failure
    End

    Example 'can not read file not specified'
      Unset SHELLSPEC_SUBJECT
      When invoke modifier entire contents _modifier_
      The status should be failure
    End

    Example 'output error if next modifier is missing'
      Set SHELLSPEC_SUBJECT="$file"
      When invoke modifier entire contents
      The entire stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
