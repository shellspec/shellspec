#shellcheck shell=sh disable=SC2016

Describe 'Assert'
  custom_assertion() {
    "$@"
  }

  Specify "Assert execute custom assertion"
    Assert custom_assertion [ "123" = "123" ]
  End
End
