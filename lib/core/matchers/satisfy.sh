#shellcheck shell=sh

shellspec_syntax 'shellspec_matcher_satisfy'

shellspec_matcher_satisfy() {
  shellspec_matcher__match() {
    # shellcheck disable=SC2034
    SHELLSPEC_EXPECT="$*"
    "$@"
  }

  shellspec_matcher__failure_message() {
    shellspec_putsn "expected $1 satisfies $2"
  }

  shellspec_matcher__failure_message_when_negated() {
    shellspec_putsn "expected $1 does not satisfy $2"
  }

  shellspec_syntax_param count [ $# -gt 0 ] || return 0
  shellspec_matcher_do_match "$@"
}
