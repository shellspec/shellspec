# shellcheck shell=sh disable=SC2016,SC2286,SC2287,SC2288

Describe 'Assert'
  custom_assertion() {
    "$@"
  }

  Specify "Assert execute custom assertion"
    Assert custom_assertion [ "123" = "123" ]
  End

  It 'does not consume stdin data.'
    Assert cat
  End
End
