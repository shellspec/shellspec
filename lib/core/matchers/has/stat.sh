#shellcheck shell=sh disable=SC2016

shellspec_syntax 'shellspec_matcher_has_setgid'
shellspec_syntax 'shellspec_matcher_has_setuid'

shellspec_matcher_has_setgid() {
  shellspec_matcher__match() {
    [ -g "${SHELLSPEC_SUBJECT:-}" ]
  }

  shellspec_syntax_failure_message + 'The $1 not have setgid flag'
  shellspec_syntax_failure_message - 'The $1 has setgid flag'

  [ "${1:-}" = "flag" ] && shift
  shellspec_syntax_param count [ $# -eq 0 ] || return 0
  shellspec_matcher_do_match
}

shellspec_matcher_has_setuid() {
  shellspec_matcher__match() {
    [ -u "${SHELLSPEC_SUBJECT:-}" ]
  }

  shellspec_syntax_failure_message + 'The $1 not have setuid flag'
  shellspec_syntax_failure_message - 'The $1 has setuid flag'

  [ "${1:-}" = "flag" ] && shift
  shellspec_syntax_param count [ $# -eq 0 ] || return 0
  shellspec_matcher_do_match
}
