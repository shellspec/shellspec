#shellcheck shell=sh


shellspec_syntax 'shellspec_matcher_diff_equal'
shellspec_syntax_compound 'shellspec_matcher_diff'

shellspec_matcher_diff_equal() {
  shellspec_matcher__match() {
    SHELLSPEC_EXPECT="$1"
    [ "${SHELLSPEC_SUBJECT+x}" ] || return 1
    cmp -s "$SHELLSPEC_SUBJECT" "$SHELLSPEC_EXPECT" || return 1
    return 0
  }

  shellspec_matcher__failure_message() {
    shellspec_putsn "Expected the same contents in $1 and $2"
    shellspec_putsn "diff $1 $2"
    shellspec_replace_all _one "$1" '"' ''
    shellspec_replace_all _two "$2" '"' ''
    shellspec_putsn "$(diff "$_one" "$_two")"
  }

  shellspec_matcher__failure_message_when_negated() {
    shellspec_putsn "Expected different contents in $1 and $2"
  }

  shellspec_syntax_param count [ $# -eq 1 ] || return 0
  shellspec_matcher_do_match "$@"
}
