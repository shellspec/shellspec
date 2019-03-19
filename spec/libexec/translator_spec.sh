#shellcheck shell=sh disable=SC2016

Describe "libexec/translator.sh"
  # shellcheck source=lib/libexec/translator.sh
  . "$SHELLSPEC_LIB/libexec/translator.sh"

  Describe "trim()"
    Context 'when value is abc'
      Before 'value="  abc"'
      Example 'trim left space'
        When call trim value
        The variable value should eq 'abc'
      End
    End

    Context 'when value is abc'
      Before 'value="${TAB}${TAB}abc"'
      Example 'trim left tab'
        When call trim value
        The variable value should eq 'abc'
      End
    End
  End
End
