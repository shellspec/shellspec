#shellcheck shell=sh

# to suppress shellcheck SC2034
: "${SHELLSPEC_META:-}" "${SHELLSPEC_SUBJECT:-}"

shellspec_syntax 'shellspec_subject_stdout'
shellspec_syntax_alias 'shellspec_subject_output' 'shellspec_subject_stdout'
shellspec_syntax 'shellspec_subject_entire_stdout'
shellspec_syntax_alias 'shellspec_subject_entire_output' 'shellspec_subject_entire_stdout'

shellspec_subject_stdout() {
  SHELLSPEC_META='text'
  if [ ${SHELLSPEC_STDOUT+x} ]; then
    SHELLSPEC_SUBJECT=${SHELLSPEC_STDOUT:-}
    shellspec_chomp SHELLSPEC_SUBJECT
  else
    unset SHELLSPEC_SUBJECT ||:
  fi

  shellspec_off UNHANDLED_STDOUT

  eval shellspec_syntax_dispatch modifier ${1+'"$@"'}
}

shellspec_subject_entire_stdout() {
  SHELLSPEC_META='text'
  if [ ${SHELLSPEC_STDOUT+x} ]; then
    SHELLSPEC_SUBJECT=${SHELLSPEC_STDOUT:-}
  else
    unset SHELLSPEC_SUBJECT ||:
  fi

  shellspec_off UNHANDLED_STDOUT

  eval shellspec_syntax_dispatch modifier ${1+'"$@"'}
}
