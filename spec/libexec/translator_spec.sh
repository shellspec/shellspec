#shellcheck shell=sh

Describe "libexec/translator.sh"
  # shellcheck source=lib/libexec/translator.sh
  . "$SHELLSPEC_LIB/libexec/translator.sh"

  Describe "trim()"
    Before set_value

    Context 'when value is abc'
      set_value() { value="  abc"; }
      Example 'trim left space'
        When call trim value
        The value "$value" should eq 'abc'
      End
    End

    Context 'when value is abc'
      set_value() { value="${TAB}${TAB}abc"; }
      Example 'trim left tab'
        When call trim value
        The value "$value" should eq 'abc'
      End
    End
  End
End
