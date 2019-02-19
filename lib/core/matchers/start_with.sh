#shellcheck shell=sh

shellspec_syntax 'shellspec_matcher_start_with'
shellspec_syntax_compound 'shellspec_matcher_start'

shellspec_matcher_start_with() {
  shellspec_matcher__match() {
    SHELLSPEC_EXPECT=$1
    case ${SHELLSPEC_SUBJECT:-} in ($SHELLSPEC_EXPECT*) return 0; esac
    return 1
  }

  shellspec_matcher__failure_message() {
    shellspec_putsn "expected $1 to start with $2"
  }

  shellspec_matcher__failure_message_when_negated() {
    shellspec_putsn "expected $1 not to start with $2"
  }

  shellspec_syntax_param count [ $# -eq 1 ] || return 0
  shellspec_matcher_do_match "$@"
}
