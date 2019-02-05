#shellcheck shell=sh

shellspec_syntax 'shellspec_modifier_length'

shellspec_modifier_length() {
  if [ "${SHELLSPEC_SUBJECT+x}" ]; then
    SHELLSPEC_SUBJECT=${#SHELLSPEC_SUBJECT}
  else
    unset SHELLSPEC_SUBJECT ||:
  fi

  eval shellspec_syntax_dispatch modifier ${1+'"$@"'}
}
