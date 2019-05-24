#shellcheck shell=sh

shellspec_syntax 'shellspec_matcher_be_empty'

shellspec_matcher_be_empty() {
  shellspec_matcher__match() {
    [ -f "${SHELLSPEC_SUBJECT:-}" ] && [ ! -s "${SHELLSPEC_SUBJECT:-}" ]
  }

  shellspec_matcher__failure_message() {
    shellspec_putsn "The specified path is not empty file"
    shellspec_putsn "path: $SHELLSPEC_SUBJECT"
  }

  shellspec_matcher__failure_message_when_negated() {
    shellspec_putsn "The specified path is empty file"
    shellspec_putsn "path: $SHELLSPEC_SUBJECT"
  }

  shellspec_syntax_param count [ $# -eq 0 ] || return 0
  shellspec_matcher_do_match
}
