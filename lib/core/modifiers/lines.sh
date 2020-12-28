#shellcheck shell=sh

shellspec_syntax 'shellspec_modifier_lines'

shellspec_modifier_lines() {
  # shellcheck disable=SC2034
  SHELLSPEC_META='number'
  if [ "${SHELLSPEC_SUBJECT+x}" ]; then
    shellspec_count_lines SHELLSPEC_SUBJECT "$SHELLSPEC_SUBJECT"
  else
    unset SHELLSPEC_SUBJECT ||:
  fi

  eval shellspec_syntax_dispatch modifier ${1+'"$@"'}
}
