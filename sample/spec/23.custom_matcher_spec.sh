#shellcheck shell=sh

# regexp custom matcher is defined in "support/custom_matcher.sh" and
# imported by "spec_helper.sh"

Describe 'custom matcher'
  Describe 'regexp'
    number() { echo 12345; }
    It 'checks with regular expression'
      When call number
      The output should regexp '[0-9]*$'
    End
  End
End
