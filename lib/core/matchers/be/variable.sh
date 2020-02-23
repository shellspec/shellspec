#shellcheck shell=sh disable=SC2016

shellspec_syntax 'shellspec_matcher_be_defined'
shellspec_syntax 'shellspec_matcher_be_undefined'
shellspec_syntax 'shellspec_matcher_be_blank'
shellspec_syntax 'shellspec_matcher_be_present'

shellspec_matcher_be_defined() {
  shellspec_matcher__match() {
    [ ${SHELLSPEC_SUBJECT+x} ]
  }

  shellspec_syntax_failure_message + \
    'expected: defined (set)' \
    '     got: $1'
  shellspec_syntax_failure_message - \
    'expected: undefined (unset)' \
    '     got: $1'

  shellspec_syntax_param count [ $# -eq 0 ] || return 0
  shellspec_matcher_do_match
}

shellspec_matcher_be_undefined() {
  shellspec_matcher__match() {
    ! [ ${SHELLSPEC_SUBJECT+x} ]
  }

  shellspec_syntax_failure_message + \
    'expected: undefined (unset)' \
    '     got: $1'
  shellspec_syntax_failure_message - \
    'expected: defined (set)' \
    '     got: $1'

  shellspec_syntax_param count [ $# -eq 0 ] || return 0
  shellspec_matcher_do_match
}

shellspec_matcher_be_present() {
  shellspec_matcher__match() {
    [ "${SHELLSPEC_SUBJECT:-}" ]
  }

  shellspec_syntax_failure_message + \
    'expected: present (non-zero length string)' \
    '     got: $1'
  shellspec_syntax_failure_message - \
    'expected: blank (unset or zero length string)' \
    '     got: $1'

  shellspec_syntax_param count [ $# -eq 0 ] || return 0
  shellspec_matcher_do_match
}

shellspec_matcher_be_blank() {
  shellspec_matcher__match() {
    ! [ "${SHELLSPEC_SUBJECT:-}" ]
  }

  shellspec_syntax_failure_message + \
    'expected: blank (unset or zero length string)' \
    '     got: $1'
  shellspec_syntax_failure_message - \
    'expected: present (non-zero length string)' \
    '     got: $1'

  shellspec_syntax_param count [ $# -eq 0 ] || return 0
  shellspec_matcher_do_match
}
