#shellcheck shell=sh disable=SC2016

shellspec_syntax 'shellspec_matcher_include'

shellspec_matcher_include() {
  shellspec_matcher__match() {
    SHELLSPEC_EXPECT=$1
    [ "${SHELLSPEC_SUBJECT+x}" ] || return 1
    shellspec_includes "$SHELLSPEC_SUBJECT" "$SHELLSPEC_EXPECT"
  }

  shellspec_syntax_failure_message + 'expected $1 to include $2'
  shellspec_syntax_failure_message - 'expected $1 not to include $2'

  shellspec_syntax_param count [ $# -eq 1 ] || return 0
  shellspec_matcher_do_match "$@"
}
