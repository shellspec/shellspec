#shellcheck shell=sh

shellspec_syntax 'shellspec_matcher_be_defined'
shellspec_syntax 'shellspec_matcher_be_undefined'
shellspec_syntax 'shellspec_matcher_be_blank'
shellspec_syntax 'shellspec_matcher_be_present'

shellspec_matcher_be_defined() {
  shellspec_matcher__match() {
    [ ${SHELLSPEC_SUBJECT+x} ]
  }

  shellspec_matcher__failure_message() {
    shellspec_putsn "expected: defined (set)"
    shellspec_putsn "     got: $1"
  }

  shellspec_matcher__failure_message_when_negated() {
    shellspec_putsn "expected: undefined (unset)"
    shellspec_putsn "     got: $1"
  }

  shellspec_syntax_param count [ $# -eq 0 ] || return 0
  shellspec_matcher_do_match
}

shellspec_matcher_be_undefined() {
  shellspec_matcher__match() {
    ! [ ${SHELLSPEC_SUBJECT+x} ]
  }

  shellspec_matcher__failure_message() {
    shellspec_putsn "expected: undefined (unset)"
    shellspec_putsn "     got: $1"
  }

  shellspec_matcher__failure_message_when_negated() {
    shellspec_putsn "expected: defined (set)"
    shellspec_putsn "     got: $1"
  }

  shellspec_syntax_param count [ $# -eq 0 ] || return 0
  shellspec_matcher_do_match
}

shellspec_matcher_be_present() {
  shellspec_matcher__match() {
    [ "${SHELLSPEC_SUBJECT:-}" ]
  }

  shellspec_matcher__failure_message() {
    shellspec_putsn "expected: present (non-zero length string)"
    shellspec_putsn "     got: $1"
  }

  shellspec_matcher__failure_message_when_negated() {
    shellspec_putsn "expected: blank (unset or zero length string)"
    shellspec_putsn "     got: $1"
  }

  shellspec_syntax_param count [ $# -eq 0 ] || return 0
  shellspec_matcher_do_match
}

shellspec_matcher_be_blank() {
  shellspec_matcher__match() {
    ! [ "${SHELLSPEC_SUBJECT:-}" ]
  }

  shellspec_matcher__failure_message() {
    shellspec_putsn "expected: blank (unset or zero length string)"
    shellspec_putsn "     got: $1"
  }

  shellspec_matcher__failure_message_when_negated() {
    shellspec_putsn "expected: present (non-zero length string)"
    shellspec_putsn "     got: $1"
  }

  shellspec_syntax_param count [ $# -eq 0 ] || return 0
  shellspec_matcher_do_match
}
