#shellcheck shell=sh

shellspec_syntax 'shellspec_verb_should'
shellspec_syntax 'shellspec_verb_should_not'

shellspec_verb_should() {
  if [ "${1:-}" = 'not' ]; then
    shift
    eval shellspec_syntax_dispatch verb should_not ${1+'"$@"'}
    return 0
  fi

  if [ $# -eq 0 ]; then
    shellspec_output SYNTAX_ERROR_MATCHER_REQUIRED
    shellspec_on SYNTAX_ERROR
  fi
  shellspec_if SYNTAX_ERROR && shellspec_on FAILED && return 0

  shellspec_proxy "shellspec_matcher_do_match" \
                  "shellspec_matcher_do_match_positive"
  shellspec_off MATCHED
  shellspec_matcher "$@"
  shellspec_if SYNTAX_ERROR && shellspec_on FAILED && return 0

  shellspec_output_if MATCHED && return 0

  shellspec_on FAILED
  shellspec_output UNMATCHED
  shellspec_output_failure_message
}

shellspec_verb_should_not() {
  if [ $# -eq 0 ]; then
    shellspec_output SYNTAX_ERROR_MATCHER_REQUIRED
    shellspec_on SYNTAX_ERROR
  fi
  shellspec_if SYNTAX_ERROR && shellspec_on FAILED && return 0

  shellspec_proxy "shellspec_matcher_do_match" \
                  "shellspec_matcher_do_match_negative"

  shellspec_off MATCHED
  shellspec_matcher "$@"
  shellspec_if SYNTAX_ERROR && shellspec_on FAILED && return 0

  shellspec_output_unless MATCHED && return 0

  shellspec_on FAILED
  shellspec_output UNMATCHED
  shellspec_output_failure_message_when_negated
}
