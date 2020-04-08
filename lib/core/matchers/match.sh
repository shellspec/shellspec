#shellcheck shell=sh disable=SC2016

shellspec_syntax_chain 'shellspec_matcher_match'
shellspec_syntax 'shellspec_matcher_match_pattern'

shellspec_matcher_match_pattern() {
  shellspec_matcher__match() {
    # shellcheck disable=SC2034
    SHELLSPEC_EXPECT=$1
    [ "${SHELLSPEC_SUBJECT+x}" ] || return 1
    shellspec_match_pattern "$SHELLSPEC_SUBJECT" "$1"
  }

  shellspec_syntax_failure_message + 'expected $1 to match pattern $2'
  shellspec_syntax_failure_message - 'expected $1 not to match pattern $2'

  shellspec_syntax_param count [ $# -eq 1 ] || return 0
  shellspec_matcher_do_match "$@"
}
