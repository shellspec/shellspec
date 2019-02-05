#shellcheck shell=sh

set -eu

shellspec_mockable shellspec_unixtime
shellspec_mockable shellspec_output
shellspec_mockable shellspec_output_failure_message
shellspec_mockable shellspec_output_failure_message_when_negated
shellspec_mockable shellspec_on
shellspec_mockable shellspec_off
shellspec_mockable shellspec_is
shellspec_mockable shellspec_syntax_dispatch
shellspec_mockable shellspec_callback

shellspec_spec_helper_configure() {
  shellspec_import 'support/custom_matcher'

  # modifier for test
  shellspec_syntax shellspec_modifier__modifier_
  shellspec_modifier__modifier_() {
    [ "${SHELLSPEC_SUBJECT+x}" ] || return 1
    shellspec_puts "$SHELLSPEC_SUBJECT"
  }

  subject() {
    shellspec_output() { shellspec_puts "$1" >&2; }
    shellspec_subject "$@"
  }

  modifier() {
    shellspec_output() { shellspec_puts "$1" >&2; }
    shellspec_modifier "$@"
  }

  matcher() {
    shellspec_output() { shellspec_puts "$1" >&2; }
    shellspec_is() { shellspec_puts "is:$*"; }
    shellspec_proxy "shellspec_matcher_do_match" \
                    "shellspec_matcher_do_match_positive"
    shellspec_matcher "$@"
    shellspec_if MATCHED
  }
}
