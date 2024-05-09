#shellcheck shell=sh

shellspec_syntax 'shellspec_subject_status'

shellspec_subject_status() {
  # shellcheck disable=SC2034
  SHELLSPEC_META='status'
  if [ ${SHELLSPEC_STATUS+x} ]; then
    # shellcheck disable=SC2034
    SHELLSPEC_SUBJECT=$SHELLSPEC_STATUS
  else
    unset SHELLSPEC_SUBJECT ||:
  fi

  shellspec_off UNHANDLED_STATUS

  case $# in
    0) shellspec_syntax_dispatch modifier ;;
    *) shellspec_syntax_dispatch modifier "$@" ;;
  esac
}
