#shellcheck shell=sh

Describe 'Timeout feature - File and integration checks'
  It 'timeout watchdog script exists'
    The path libexec/shellspec-timeout-watchdog.sh should be exist
  End

  It 'timeout watchdog script is executable'
    The path libexec/shellspec-timeout-watchdog.sh should be executable
  End

  It 'timeout parser script exists'
    The path lib/libexec/timeout-parser.sh should be exist
  End

  It 'timeout directive exists in grammar'
    The file lib/libexec/grammar/directives should be exist
    The contents of file lib/libexec/grammar/directives should include "%timeout"
  End

  It 'dsl.sh contains timeout integration code'
    The file lib/core/dsl.sh should be exist
    The contents of file lib/core/dsl.sh should include "SHELLSPEC_TIMEOUT_SIGNAL_FILE"
    The contents of file lib/core/dsl.sh should include "shellspec_timeout_occurred"
  End

  It 'outputs.sh contains TIMEOUT handler'
    The file lib/core/outputs.sh should be exist
    The contents of file lib/core/dsl.sh should include "shellspec_output TIMEOUT"
  End

  It 'bootstrap.sh loads timeout parser'
    The file lib/bootstrap.sh should be exist
    The contents of file lib/bootstrap.sh should include "timeout-parser.sh"
  End

  It 'translator.sh handles timeout metadata'
    The file lib/libexec/translator.sh should be exist
    The contents of file lib/libexec/translator.sh should include "timeout_metadata"
    The contents of file lib/libexec/translator.sh should include "shellspec_timeout_override"
  End

  It 'translate.sh passes timeout variable to generated code'
    The file libexec/shellspec-translate.sh should be exist
    The contents of file libexec/shellspec-translate.sh should include "SHELLSPEC_EXAMPLE_TIMEOUT"
  End

  It 'option parser includes timeout options'
    The file lib/libexec/optparser/parser_definition_generated.sh should be exist
    The contents of file lib/libexec/optparser/parser_definition_generated.sh should include "SHELLSPEC_TIMEOUT"
  End

  It 'parser definition includes timeout option'
    The file lib/libexec/optparser/parser_definition.sh should be exist
    The contents of file lib/libexec/optparser/parser_definition.sh should include "--timeout"
    The contents of file lib/libexec/optparser/parser_definition.sh should include "--no-timeout"
  End

  It 'optparser includes timeout validation'
    The file lib/libexec/optparser/optparser.sh should be exist
    The contents of file lib/libexec/optparser/optparser.sh should include "check_timeout_format"
  End
End
