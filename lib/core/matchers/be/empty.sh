#shellcheck shell=sh disable=SC2016

shellspec_syntax 'shellspec_matcher_be_empty_file'
shellspec_syntax 'shellspec_matcher_be_empty_directory'
shellspec_syntax_alias 'shellspec_matcher_be_empty_dir' 'shellspec_matcher_be_empty_directory'
shellspec_syntax_compound 'shellspec_matcher_be_empty'

shellspec_matcher_be_empty_file() {
  shellspec_matcher__match() {
    [ -f "${SHELLSPEC_SUBJECT:-}" ] && [ ! -s "${SHELLSPEC_SUBJECT:-}" ]
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
    [ -d "${SHELLSPEC_SUBJECT:-}" ] || return 1

    # This subshell is used to revert changes directory, $OLDPWD, set, shopt
    ( :
      # set -- "$DIR"/* not working properly in posh 0.10.2
      cd "$SHELLSPEC_SUBJECT" || return 1

      set +o noglob
      case $SHELLSPEC_SHELL_TYPE in
        zsh) setopt NO_NOMATCH ;;
        bash) { eval shopt -u failglob ||:; } 2>/dev/null ;;
        posh) set +u ;; # glob does not expand when set -u in posh 0.10.2
      esac
      set -- * .*

      while [ $# -gt 0 ]; do
        case $1 in (.|..) false; esac && [ -e "$1" ] && break
        shift
      done
      [ $# -eq 0 ] &&:
    )
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
