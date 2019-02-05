#shellcheck shell=sh

shellspec_syntax 'shellspec_matcher_equal'
shellspec_syntax_alias 'shellspec_matcher_eq' 'shellspec_matcher_equal'

shellspec_matcher_equal() {
  shellspec_matcher_match() {
    SHELLSPEC_EXPECT="$1"
    [ "${SHELLSPEC_SUBJECT+x}" ] || return 1
    [ "$SHELLSPEC_SUBJECT" = "$SHELLSPEC_EXPECT" ] || return 1
    return 0
  }

  shellspec_matcher_failure_message() {
    shellspec_putsn "expected: $2"
    shellspec_putsn "     got: $1"
  }

  shellspec_matcher_failure_message_when_negated() {
    shellspec_putsn "expected: not equal $2"
    shellspec_putsn "     got: $1"
  }

  shellspec_syntax_param count [ $# -eq 1 ] || return 0
  shellspec_matcher_do_match "$@"
}
