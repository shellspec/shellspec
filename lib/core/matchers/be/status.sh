#shellcheck shell=sh disable=SC2016

shellspec_syntax 'shellspec_matcher_be_success'
shellspec_syntax 'shellspec_matcher_be_failure'

shellspec_matcher_be_success() {
  shellspec_matcher__match() {
    [ _"${SHELLSPEC_SUBJECT:-}" = _0 ]
  }

  shellspec_syntax_failure_message + \
    'expected: success (zero)' \
    '     got: failure (non-zero) [status: $1]'
  shellspec_syntax_failure_message - \
    'expected: failure (non-zero)' \
    '     got: success (zero) [status: $1]'

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

  shellspec_syntax_failure_message + \
    'expected: failure (non-zero)' \
    '     got: success (zero) [status: $1]'
  shellspec_syntax_failure_message - \
    'expected: success (zero)' \
    '     got: failure (non-zero) [status: $1]'

  shellspec_syntax_param count [ $# -eq 0 ] || return 0
  shellspec_matcher_do_match
}
