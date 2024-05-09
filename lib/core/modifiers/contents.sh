#shellcheck shell=sh

shellspec_syntax 'shellspec_modifier_contents'
shellspec_syntax 'shellspec_modifier_entire_contents'

shellspec_modifier_contents() {
  # shellcheck disable=SC2034
  SHELLSPEC_META='text'
  if [ "${SHELLSPEC_SUBJECT+x}" ] && [ -e "${SHELLSPEC_SUBJECT:-}" ]; then
    shellspec_capturefile SHELLSPEC_SUBJECT "$SHELLSPEC_SUBJECT"
  else
    unset SHELLSPEC_SUBJECT ||:
  fi

  case $# in
    0) shellspec_syntax_dispatch modifier ;;
    *) shellspec_syntax_dispatch modifier "$@" ;;
  esac
}

shellspec_modifier_entire_contents() {
  # shellcheck disable=SC2034
  SHELLSPEC_META='text'
  if [ "${SHELLSPEC_SUBJECT+x}" ] && [ -e "$SHELLSPEC_SUBJECT" ]; then
    shellspec_readfile SHELLSPEC_SUBJECT "$SHELLSPEC_SUBJECT"
  else
    unset SHELLSPEC_SUBJECT ||:
  fi

  case $# in
    0) shellspec_syntax_dispatch modifier ;;
    *) shellspec_syntax_dispatch modifier "$@" ;;
  esac
}
