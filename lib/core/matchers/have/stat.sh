#shellcheck shell=sh disable=SC2016

shellspec_syntax 'shellspec_matcher_have_setgid'
shellspec_syntax 'shellspec_matcher_have_setuid'

# deprecated
shellspec_syntax_alias 'shellspec_matcher_has_setgid' 'shellspec_matcher_have_setgid'
shellspec_syntax_alias 'shellspec_matcher_has_setuid' 'shellspec_matcher_have_setuid'

shellspec_matcher_have_setgid() {
  shellspec_matcher__match() {
    [ -g "${SHELLSPEC_SUBJECT:-}" ]
  }

  shellspec_syntax_failure_message + 'The $1 does not have the setgid flag'
  shellspec_syntax_failure_message - 'The $1 has the setgid flag'

  [ "${1:-}" = "flag" ] && shift
  shellspec_syntax_param count [ $# -eq 0 ] || return 0
  shellspec_matcher_do_match
}

shellspec_matcher_have_setuid() {
  shellspec_matcher__match() {
    [ -u "${SHELLSPEC_SUBJECT:-}" ]
  }

  shellspec_syntax_failure_message + 'The $1 does not have the setuid flag'
  shellspec_syntax_failure_message - 'The $1 has the setuid flag'

  [ "${1:-}" = "flag" ] && shift
  shellspec_syntax_param count [ $# -eq 0 ] || return 0
  shellspec_matcher_do_match
}
