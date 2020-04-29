#shellcheck shell=sh disable=SC2016

shellspec_syntax 'shellspec_matcher_be_empty_file'
shellspec_syntax 'shellspec_matcher_be_empty_directory'
shellspec_syntax_alias 'shellspec_matcher_be_empty_dir' 'shellspec_matcher_be_empty_directory'
shellspec_syntax_compound 'shellspec_matcher_be_empty'

shellspec_matcher_be_empty_file() {
  shellspec_matcher__match() {
    shellspec_is_empty_file "${SHELLSPEC_SUBJECT:-}"
  }

  shellspec_syntax_failure_message + \
    'The specified path is not empty file' \
    'path: $SHELLSPEC_SUBJECT'
  shellspec_syntax_failure_message - \
    'The specified path is empty file' \
    'path: $SHELLSPEC_SUBJECT'

  shellspec_syntax_param count [ $# -eq 0 ] || return 0
  shellspec_matcher_do_match
}

shellspec_matcher_be_empty_directory() {
  shellspec_matcher__match() {
    shellspec_is_empty_directory "${SHELLSPEC_SUBJECT:-}"
  }

  shellspec_syntax_failure_message + \
    'The specified path is not empty directory' \
    'path: $SHELLSPEC_SUBJECT'
  shellspec_syntax_failure_message - \
    'The specified path is empty directory' \
    'path: $SHELLSPEC_SUBJECT'

  shellspec_syntax_param count [ $# -eq 0 ] || return 0
  shellspec_matcher_do_match
}
