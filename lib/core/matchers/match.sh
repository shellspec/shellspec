#shellcheck shell=sh

shellspec_syntax 'shellspec_matcher_match'

shellspec_matcher_match() {
  if [ "${1:-}" = "pattern" ]; then
    shift
    eval shellspec_matcher_match_pattern ${1+'"$@"'}
    return $?
  fi

  shellspec_deprecated "'match' matcher deprecated, use 'match pattern' matcher instead"
  shellspec_syntax_param count [ $# -eq 1 ] || return 0
  shellspec_matcher_deprecated_match "$@"
}

shellspec_matcher_deprecated_match() {
  shellspec_matcher__match() {
    # shellcheck disable=SC2034
    SHELLSPEC_EXPECT=$1
    [ "${SHELLSPEC_SUBJECT+x}" ] || return 1
    shellspec_match "$SHELLSPEC_SUBJECT" "$1"
  }

  shellspec_matcher__failure_message() {
    shellspec_putsn "expected $1 to match $2"
  }

  shellspec_matcher__failure_message_when_negated() {
    shellspec_putsn "expected $1 not to match $2"
  }

  shellspec_syntax_param count [ $# -eq 1 ] || return 0
  shellspec_matcher_do_match "$@"
}

shellspec_matcher_match_pattern() {
  shellspec_matcher__match() {
    # shellcheck disable=SC2034
    SHELLSPEC_EXPECT=$1
    [ "${SHELLSPEC_SUBJECT+x}" ] || return 1
    shellspec_match_pattern "$SHELLSPEC_SUBJECT" "$1"
  }

  shellspec_matcher__failure_message() {
    shellspec_putsn "expected $1 to match pattern $2"
  }

  shellspec_matcher__failure_message_when_negated() {
    shellspec_putsn "expected $1 not to match pattern $2"
  }

  shellspec_syntax_param count [ $# -eq 1 ] || return 0
  shellspec_matcher_do_match "$@"
}
