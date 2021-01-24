#shellcheck shell=sh

shellspec_syntax 'shellspec_matcher_be_size'

shellspec_matcher_be_size() {
  shellspec_matcher__match() {
    # expected item count
    SHELLSPEC_EXPECT="$1"

    # fail if SHELLSPEC_SUBJECT undefined
    [ "${SHELLSPEC_SUBJECT+x}" ] || return 1

    # fail if different size
    [ "${#SHELLSPEC_SUBJECT[@]}" -eq "$SHELLSPEC_EXPECT" ] || return 1

    # success
    return 0
  }

  #shellcheck disable=SC2016
  shellspec_syntax_failure_message + \
      'expected ${#SHELLSPEC_SUBJECT[@]} to be $2' \
      'array: ${SHELLSPEC_SUBJECT[@]}'

  #shellcheck disable=SC2016
  shellspec_syntax_failure_message - \
      'expected ${#SHELLSPEC_SUBJECT[@]} to not be $2' \
      'array: ${SHELLSPEC_SUBJECT[@]}'

  shellspec_syntax_param count [ $# -eq 1 ] || return 0
  shellspec_matcher_do_match "$@"
}
