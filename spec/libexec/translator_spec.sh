#shellcheck shell=sh

Describe "libexec/translator.sh"
  # shellcheck source=lib/libexec/translator.sh
  . "$SHELLSPEC_LIB/libexec/translator.sh"

  Describe "trim()"
    Before set_value

    Context 'when value is abc'
      set_value() { value="  abc"; }
      It 'trims left space'
        When call trim value
        The value "$value" should eq 'abc'
      End
    End

    Context 'when value is <TAB><TAB>abc'
      set_value() { value="${TAB}${TAB}abc"; }
      It 'trims left tab'
        When call trim value
        The value "$value" should eq 'abc'
      End
    End
  End

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
