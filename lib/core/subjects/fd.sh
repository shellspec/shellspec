#shellcheck shell=sh

shellspec_syntax 'shellspec_subject_fd'
shellspec_syntax 'shellspec_subject_entire_fd'

shellspec_subject_fd() {
  shellspec_syntax_param count [ $# -ge 1 ] || return 0

  # shellcheck disable=SC2034
  SHELLSPEC_META='text'
  SHELLSPEC_SUBJECT="$SHELLSPEC_STDIO_FILE_BASE.fd-${1}"
  if [ -e "$SHELLSPEC_SUBJECT" ]; then
    # shellcheck disable=SC2034
    shellspec_capturefile SHELLSPEC_SUBJECT "$SHELLSPEC_SUBJECT"
  else
    unset SHELLSPEC_SUBJECT ||:
  fi
  shift

  eval shellspec_syntax_dispatch modifier ${1+'"$@"'}
}

shellspec_subject_entire_fd() {
  shellspec_syntax_param count [ $# -ge 1 ] || return 0

  # shellcheck disable=SC2034
  SHELLSPEC_META='text'
  SHELLSPEC_SUBJECT="$SHELLSPEC_STDIO_FILE_BASE.fd-${1}"
  if [ -e "$SHELLSPEC_SUBJECT" ]; then
    # shellcheck disable=SC2034
    shellspec_readfile SHELLSPEC_SUBJECT "$SHELLSPEC_SUBJECT"
  else
    unset SHELLSPEC_SUBJECT ||:
  fi
  shift

  eval shellspec_syntax_dispatch modifier ${1+'"$@"'}
}
