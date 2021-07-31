shellspec_syntax 'shellspec_matcher_exist'

shellspec_matcher_exist() {
  shellspec_matcher__match() {
    [ -e "${SHELLSPEC_SUBJECT:-}" ]
    return 0
  }

  shellspec_syntax_failure_message + \
    'expected $1 to exist'
  shellspec_syntax_failure_message - \
    'did not expect $1 to exist'

  shellspec_syntax_param count [ $# -eq 0 ] || return 0
  shellspec_matcher_do_match "$@"
}
