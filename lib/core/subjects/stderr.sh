#shellcheck shell=sh

shellspec_syntax 'shellspec_subject_stderr'
shellspec_syntax_alias 'shellspec_subject_error' 'shellspec_subject_stderr'
shellspec_syntax 'shellspec_subject_entire_stderr'
shellspec_syntax_alias 'shellspec_subject_entire_error' 'shellspec_subject_entire_stderr'

shellspec_subject_stderr() {
  # shellcheck disable=SC2034
  SHELLSPEC_META='text'
  if [ ${SHELLSPEC_STDERR+x} ]; then
    # shellcheck disable=SC2034
    SHELLSPEC_SUBJECT=$SHELLSPEC_STDERR
    shellspec_chomp SHELLSPEC_SUBJECT
  else
    unset SHELLSPEC_SUBJECT ||:
  fi

  shellspec_off UNHANDLED_STDERR

  eval shellspec_syntax_dispatch modifier ${1+'"$@"'}
}

shellspec_subject_entire_stderr() {
  # shellcheck disable=SC2034
  SHELLSPEC_META='text'
  if [ ${SHELLSPEC_STDERR+x} ]; then
    # shellcheck disable=SC2034
    SHELLSPEC_SUBJECT=$SHELLSPEC_STDERR
  else
    unset SHELLSPEC_SUBJECT ||:
  fi

  shellspec_off UNHANDLED_STDERR

  eval shellspec_syntax_dispatch modifier ${1+'"$@"'}
}
