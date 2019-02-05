#shellcheck shell=sh

# to suppress shellcheck SC2034
: "${SHELLSPEC_SUBJECT:-}"

shellspec_syntax 'shellspec_subject_exit_status'
shellspec_syntax_compound 'shellspec_subject_exit'
shellspec_syntax_alias 'shellspec_subject_status' 'shellspec_subject_exit_status'

shellspec_subject_exit_status() {
  if [ ${SHELLSPEC_EXIT_STATUS+x} ]; then
    SHELLSPEC_SUBJECT="$SHELLSPEC_EXIT_STATUS"
  else
    unset SHELLSPEC_SUBJECT ||:
  fi

  shellspec_off UNHANDLED_STATUS

  eval shellspec_syntax_dispatch modifier ${1+'"$@"'}
}
