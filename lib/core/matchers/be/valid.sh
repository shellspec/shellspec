#shellcheck shell=sh disable=SC2016

shellspec_syntax 'shellspec_matcher_be_valid_number'
shellspec_syntax 'shellspec_matcher_be_valid_funcname'
shellspec_syntax_chain 'shellspec_matcher_be_valid'

shellspec_matcher_be_valid_number() {
  shellspec_matcher__match() {
    shellspec_is_number "${SHELLSPEC_SUBJECT:-}"
  }

  shellspec_syntax_failure_message + 'expected $1 is valid as a number'
  shellspec_syntax_failure_message - 'expected $1 is not valid as a number'

  shellspec_syntax_param count [ $# -eq 0 ] || return 0
  shellspec_matcher_do_match
}

shellspec_matcher_be_valid_funcname() {
  shellspec_matcher__match() {
    shellspec_is_function "${SHELLSPEC_SUBJECT:-}"
  }

  shellspec_syntax_failure_message + 'expected $1 is valid as a funcname'
  shellspec_syntax_failure_message - 'expected $1 is not valid as a funcname'

  shellspec_syntax_param count [ $# -eq 0 ] || return 0
  shellspec_matcher_do_match
}
