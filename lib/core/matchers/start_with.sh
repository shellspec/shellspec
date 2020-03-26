#shellcheck shell=sh disable=SC2016

shellspec_syntax 'shellspec_matcher_start_with'
shellspec_syntax_compound 'shellspec_matcher_start'

shellspec_matcher_start_with() {
  shellspec_matcher__match() {
    SHELLSPEC_EXPECT=$1
    [ "${SHELLSPEC_SUBJECT+x}" ] || return 1
    shellspec_starts_with "$SHELLSPEC_SUBJECT" "$SHELLSPEC_EXPECT"
  }

  shellspec_syntax_failure_message + 'expected $1 to start with $2'
  shellspec_syntax_failure_message - 'expected $1 not to start with $2'

  shellspec_syntax_param count [ $# -eq 1 ] || return 0
  shellspec_matcher_do_match "$@"
}
