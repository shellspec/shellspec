#shellcheck shell=sh

set -eu

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
IFS="$SHELLSPEC_LF$SHELLSPEC_TAB"

# Workaround for ksh
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

# Workaround for busybox-1.1.3
shellspec_unbuiltin "ps"
shellspec_unbuiltin "last"
shellspec_unbuiltin "sleep"
shellspec_unbuiltin "date"
shellspec_unbuiltin "wget"
shellspec_unbuiltin "mkdir"

shellspec_spec_helper_configure() {
  shellspec_import 'support/custom_matcher'

  set_subject() {
    shellspec_capture SHELLSPEC_SUBJECT subject
  }

  set_status() {
    shellspec_capture SHELLSPEC_STATUS status
  }

  set_stdout() {
    shellspec_capture SHELLSPEC_STDOUT stdout
  }

  set_stderr() {
    shellspec_capture SHELLSPEC_STDERR stderr
  }

  # modifier for test
  shellspec_syntax shellspec_modifier__modifier_
  shellspec_modifier__modifier_() {
    [ "${SHELLSPEC_SUBJECT+x}" ] || return 1
    shellspec_puts "$SHELLSPEC_SUBJECT"
  }

  subject_mock() {
    shellspec_output() { shellspec_puts "$1" >&2; }
  }

  modifier_mock() {
    shellspec_output() { shellspec_puts "$1" >&2; }
  }

  matcher_mock() {
    shellspec_output() { shellspec_puts "$1" >&2; }
    shellspec_proxy "shellspec_matcher_do_match" "shellspec_matcher__match"
  }

  shellspec_syntax_alias 'shellspec_subject_switch' 'shellspec_subject_value'
  switch_on() { shellspec_if "$SHELLSPEC_SUBJECT"; }
  switch_off() { shellspec_unless "$SHELLSPEC_SUBJECT"; }

  posh_pattern_matching_bug() {
    # shellcheck disable=SC2194
    case "a[d]" in (*"a[d]"*) false; esac # posh <= 0.12.6
  }

  not_exist_failglob() {
    #shellcheck disable=SC2039
    shopt -s failglob 2>/dev/null && return 1
    return 0
  }

  exists_tty() {
    (: < /dev/tty) 2>/dev/null
  }

  invalid_posix_parameter_expansion() {
    set -- "a*b" "a[*]"
    [ "${1#"$2"}" = "a*b" ] && return 1 || return 0
  }
}
