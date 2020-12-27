#shellcheck shell=sh

set -eu

wa_loaded() {
  # for ksh
  shellspec_redefinable shellspec_puts
  shellspec_redefinable shellspec_putsn
  shellspec_redefinable shellspec_output
  shellspec_redefinable shellspec_output_failure_message
  shellspec_redefinable shellspec_output_failure_message_when_negated
  shellspec_redefinable shellspec_on
  shellspec_redefinable shellspec_off
  shellspec_redefinable shellspec_yield
  shellspec_redefinable shellspec_parameters
  shellspec_redefinable shellspec_profile_start
  shellspec_redefinable shellspec_profile_end
  shellspec_redefinable shellspec_invoke_example
  shellspec_redefinable shellspec_statement_evaluation
  shellspec_redefinable shellspec_statement_preposition
  shellspec_redefinable shellspec_append_shell_option
  shellspec_redefinable shellspec_evaluation_cleanup
  shellspec_redefinable shellspec_statement_ordinal
  shellspec_redefinable shellspec_statement_subject
  shellspec_redefinable shellspec_subject
  shellspec_redefinable shellspec_syntax_dispatch
  shellspec_redefinable shellspec_set_long
  shellspec_redefinable shellspec_import
  shellspec_redefinable shellspec_clone
  shellspec_redefinable shellspec_clone_typeset
  shellspec_redefinable shellspec_clone_set
  shellspec_redefinable shellspec_clone_exists_variable
  shellspec_redefinable shellspec_rm
  shellspec_redefinable shellspec_chmod
  shellspec_redefinable shellspec_mv
  shellspec_redefinable shellspec_create_mock_file
  shellspec_redefinable shellspec_gen_mock_code
  shellspec_redefinable shellspec_is_function
  shellspec_redefinable shellspec_sleep
  shellspec_redefinable shellspec_source

  # for busybox-1.1.3, ksh88
  shellspec_unbuiltin "ps"
  shellspec_unbuiltin "last"
  shellspec_unbuiltin "sleep"
  shellspec_unbuiltin "date"
  shellspec_unbuiltin "wget"
  shellspec_unbuiltin "mkdir"
  shellspec_unbuiltin "kill"
  shellspec_unbuiltin "env"
  shellspec_unbuiltin "cat"
  shellspec_unbuiltin "od"
  shellspec_unbuiltin "hexdump"
  shellspec_unbuiltin "tar"
  shellspec_unbuiltin "cd"
}
