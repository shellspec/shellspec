#shellcheck shell=sh

# to suppress shellcheck SC2034
: "${SHELLSPEC_META:-}" "${SHELLSPEC_SUBJECT:-}"

shellspec_syntax 'shellspec_subject_status'

shellspec_subject_status() {
  SHELLSPEC_META='status'
  if [ ${SHELLSPEC_STATUS+x} ]; then
    SHELLSPEC_SUBJECT="$SHELLSPEC_STATUS"
  else
    unset SHELLSPEC_SUBJECT ||:
  fi

  shellspec_off UNHANDLED_STATUS

  eval shellspec_syntax_dispatch modifier ${1+'"$@"'}
}
