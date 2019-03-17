#shellcheck shell=sh

Describe "libexec/translator.sh"
  # shellcheck source=lib/libexec/translator.sh
  . "$SHELLSPEC_LIB/libexec/translator.sh"

  Describe "trim()"
    Example 'trim left space'
      Set value="  abc"
      When call trim value
      The variable value should eq 'abc'
    End

    Example 'trim left tab'
      Set value="${SHELLSPEC_TAB}${SHELLSPEC_TAB}abc"
      When call trim value
      The variable value should eq 'abc'
    End
  End
End
