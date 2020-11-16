#shellcheck shell=sh

Describe "libexec/parser_definition.sh"
  Include "$SHELLSPEC_LIB/getoptions.sh"
  Include "$SHELLSPEC_LIB/getoptions_help.sh"
  Include "$SHELLSPEC_LIB/getoptions_abbr.sh"
  Include "$SHELLSPEC_LIB/libexec/parser_definition.sh"

  It "generates option parser"
    When call getoptions parser_definition parse_options SHELLSPEC error_message
    The output should be present
    The status should be success
  End
End
