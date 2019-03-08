#shellcheck shell=sh

shellspec_syntax 'shellspec_modifier_lines'

shellspec_modifier_lines() {
  if [ "${SHELLSPEC_SUBJECT+x}" ]; then
    shellspec_get_lines SHELLSPEC_SUBJECT "$SHELLSPEC_SUBJECT"
  else
    unset SHELLSPEC_SUBJECT ||:
  fi

  eval shellspec_syntax_dispatch modifier ${1+'"$@"'}
}
