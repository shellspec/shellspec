# shellcheck shell=sh disable=SC2016,SC2286,SC2287,SC2288

Describe 'cov/kcov.sh'
  Describe 'shellspec_coverage_setup()'
    It "setups coverage feature"
      When run shellspec_coverage_setup "$SHELLSPEC_SHELL_TYPE"
      The status should be success
    End
  End
End
