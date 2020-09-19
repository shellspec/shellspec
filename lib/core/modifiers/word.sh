#shellcheck shell=sh

shellspec_syntax 'shellspec_modifier_word'

shellspec_modifier_word() {
  shellspec_syntax_param count [ $# -ge 1 ] || return 0
  shellspec_syntax_param 1 is number "$1" || return 0

  # shellcheck disable=SC2034
  SHELLSPEC_META='text'
  if [ "${SHELLSPEC_SUBJECT+x}" ]; then
    if ! shellspec_get_nth SHELLSPEC_SUBJECT "$SHELLSPEC_SUBJECT" "$1"; then
      unset SHELLSPEC_SUBJECT ||:
    fi
  else
    unset SHELLSPEC_SUBJECT ||:
  fi
  shift

  eval shellspec_syntax_dispatch modifier ${1+'"$@"'}
}
