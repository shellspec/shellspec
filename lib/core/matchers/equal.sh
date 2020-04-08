#shellcheck shell=sh disable=SC2016

shellspec_syntax 'shellspec_matcher_equal'
shellspec_syntax_alias 'shellspec_matcher_eq' 'shellspec_matcher_equal'

shellspec_matcher_equal() {
  shellspec_matcher__match() {
    SHELLSPEC_EXPECT="$1"
    [ "${SHELLSPEC_SUBJECT+x}" ] || return 1
    [ _"$SHELLSPEC_SUBJECT" = _"$SHELLSPEC_EXPECT" ] || return 1
    return 0
  }

  shellspec_syntax_failure_message + \
    'expected: $2' \
    '     got: $1'
  shellspec_syntax_failure_message - \
    'expected: not equal $2' \
    '     got: $1'

  shellspec_syntax_param count [ $# -eq 1 ] || return 0
  shellspec_matcher_do_match "$@"
}
