#shellcheck shell=sh

: "${SHELLSPEC_EXPECT:-}"

shellspec_matcher() {

  shellspec_proxy "shellspec_matcher__match_when_negated" \
                  "! shellspec_matcher__match"

  # $1: formatted subject, $: formatted expect
  shellspec_matcher__failure_message() {
    shellspec_putsn "subject: $1"
  }

  shellspec_proxy "shellspec_matcher__failure_message_when_negated" \
                  "shellspec_matcher__failure_message"

  unset SHELLSPEC_EXPECT ||:

  eval shellspec_syntax_dispatch matcher ${1+'"$@"'}
}

shellspec_matcher_do_match_positive() {
  if eval "shellspec_matcher__match ${1+\"\$@\"} &&:"; then
    shellspec_on MATCHED
  fi
}

shellspec_matcher_do_match_negative() {
  if ! eval "shellspec_matcher__match_when_negated ${1+\"\$@\"} &&:"; then
    shellspec_on MATCHED
  fi
}

shellspec_import 'core/matchers/be'
shellspec_import 'core/matchers/end_with'
shellspec_import 'core/matchers/equal'
shellspec_import 'core/matchers/has'
shellspec_import 'core/matchers/include'
shellspec_import 'core/matchers/match'
shellspec_import 'core/matchers/start_with'
shellspec_import 'core/matchers/satisfy'
