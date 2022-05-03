# shellcheck shell=sh disable=SC2016,SC2286,SC2287,SC2288

Describe "shellspec-inspection.sh"
  It "inspects shell capabilities"
    When run script ./libexec/shellspec-inspection.sh
    The output should be defined
    The status should be success
  End
End
