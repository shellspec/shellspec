#shellcheck shell=sh disable=SC2016

shellspec_syntax 'shellspec_matcher_be_defined'
shellspec_syntax 'shellspec_matcher_be_undefined'
shellspec_syntax 'shellspec_matcher_be_blank'
shellspec_syntax 'shellspec_matcher_be_present'
shellspec_syntax 'shellspec_matcher_be_exported'
shellspec_syntax 'shellspec_matcher_be_readonly'

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
    [ _"${SHELLSPEC_SUBJECT:-}" != _"" ]
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
    [ _"${SHELLSPEC_SUBJECT:-}" = _"" ]
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

shellspec_matcher_be_exported() {
  shellspec_matcher__match() {
    if [ "${SHELLSPEC_META#variable:}" = "$SHELLSPEC_META" ]; then
      shellspec_output SYNTAX_ERROR "The subject is not a variable"
      shellspec_on SYNTAX_ERROR
      return 0
    fi

    shellspec_exists_envkey "${SHELLSPEC_META#*:}"
  }

  shellspec_syntax_failure_message + 'The specified variable is not exported'
  shellspec_syntax_failure_message - 'The specified variable is exported'

  shellspec_syntax_param count [ $# -eq 0 ] || return 0
  shellspec_matcher_do_match
}

shellspec_matcher_be_readonly() {
  shellspec_matcher__match() {
    if [ "${SHELLSPEC_META#variable:}" = "$SHELLSPEC_META" ]; then
      shellspec_output SYNTAX_ERROR "The subject is not a variable"
      shellspec_on SYNTAX_ERROR
      return 0
    fi

    shellspec_is_readonly "${SHELLSPEC_META#*:}"
  }

  shellspec_syntax_failure_message + 'The specified variable is not readonly'
  shellspec_syntax_failure_message - 'The specified variable is readonly'

  shellspec_syntax_param count [ $# -eq 0 ] || return 0
  shellspec_matcher_do_match
}
