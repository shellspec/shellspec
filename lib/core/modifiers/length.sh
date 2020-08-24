#shellcheck shell=sh

# to suppress shellcheck SC2034
: "${SHELLSPEC_META:-}"

shellspec_syntax 'shellspec_modifier_length'

shellspec_modifier_length() {
  SHELLSPEC_META='number'
  if [ "${SHELLSPEC_SUBJECT+x}" ]; then
    SHELLSPEC_SUBJECT=${#SHELLSPEC_SUBJECT}
  else
    unset SHELLSPEC_SUBJECT ||:
  fi

  eval shellspec_syntax_dispatch modifier ${1+'"$@"'}
}
