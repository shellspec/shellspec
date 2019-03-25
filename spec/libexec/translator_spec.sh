#shellcheck shell=sh

Describe "libexec/translator.sh"
  # shellcheck source=lib/libexec/translator.sh
  . "$SHELLSPEC_LIB/libexec/translator.sh"

  Describe "syntax_check()"
    It 'succeeds with valid syntax'
      When call syntax_check :
      The status should be success
      The stdout should not be present
    End

    It 'fail with invalid syntax'
      When call syntax_check "'Unterminated quoted string"
      The status should be failure
      The stdout should be present
    End
  End
End
