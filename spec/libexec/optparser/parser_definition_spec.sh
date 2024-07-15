# shellcheck shell=sh disable=SC2016,SC2286,SC2287,SC2288

Describe "libexec/optparser/parser_definition.sh"
  Include "$SHELLSPEC_LIB/getoptions_base.sh"
  Include "$SHELLSPEC_LIB/getoptions_help.sh"
  Include "$SHELLSPEC_LIB/getoptions_abbr.sh"
  Include "$SHELLSPEC_LIB/libexec/optparser/parser_definition.sh"

  It "generates option parser"
    When call getoptions parser_definition parse_options SHELLSPEC error_message
    The output should be present
    The status should be success
  End
End
