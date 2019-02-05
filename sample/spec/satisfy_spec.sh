#shellcheck shell=sh

Describe 'satisfy'
  check() { [ "$SHELLSPEC_SUBJECT" = "123" ]; }

  Example 'satisfy matcher'
    When call true
    The value 123 should satisfy check
  End
End
