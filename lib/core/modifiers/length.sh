#shellcheck shell=sh

shellspec_syntax 'shellspec_modifier_length'

shellspec_modifier_length() {
  # shellcheck disable=SC2034
  SHELLSPEC_META='number'
  if [ "${SHELLSPEC_SUBJECT+x}" ]; then
    SHELLSPEC_SUBJECT=${#SHELLSPEC_SUBJECT}
  else
    unset SHELLSPEC_SUBJECT ||:
  fi

  case $# in
    0) shellspec_syntax_dispatch modifier ;;
    *) shellspec_syntax_dispatch modifier "$@" ;;
  esac
}
