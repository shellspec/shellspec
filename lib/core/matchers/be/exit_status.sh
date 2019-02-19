#shellcheck shell=sh

shellspec_syntax 'shellspec_matcher_be_success'
shellspec_syntax 'shellspec_matcher_be_failure'

shellspec_matcher_be_success() {
  shellspec_matcher__match() {
    [ "${SHELLSPEC_SUBJECT:-}" = 0 ]
  }

  shellspec_matcher__failure_message() {
    shellspec_putsn "expected: success (zero)"
    shellspec_putsn "     got: failure (non-zero) [exit status: $1]"
  }

  shellspec_matcher__failure_message_when_negated() {
    shellspec_putsn "expected: failure (non-zero)"
    shellspec_putsn "     got: success (zero) [exit status: $1]"
  }

  shellspec_syntax_param count [ $# -eq 0 ] || return 0
  shellspec_matcher_do_match
}

shellspec_matcher_be_failure() {
  shellspec_matcher__match() {
    case ${SHELLSPEC_SUBJECT:-} in ("" | *[!0-9]*) return 1; esac
    [ "$SHELLSPEC_SUBJECT" -eq 0 ] && return 1
    [ "$SHELLSPEC_SUBJECT" -gt 255 ] && return 1
    return 0
  }

  shellspec_matcher__failure_message() {
    shellspec_putsn "expected: failure (non-zero)"
    shellspec_putsn "     got: success (zero) [exit status: $1]"
  }

  shellspec_matcher__failure_message_when_negated() {
    shellspec_putsn "expected: success (zero)"
    shellspec_putsn "     got: failure (non-zero) [exit status: $1]"
  }

  shellspec_syntax_param count [ $# -eq 0 ] || return 0
  shellspec_matcher_do_match
}
