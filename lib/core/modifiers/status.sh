#shellcheck shell=sh

shellspec_syntax 'shellspec_modifier_status'

shellspec_modifier_status() {
  if [ "${SHELLSPEC_SUBJECT+x}" ]; then
    "$SHELLSPEC_SUBJECT">/dev/null &&:
    SHELLSPEC_SUBJECT=$?
  else
    unset SHELLSPEC_SUBJECT ||:
  fi

  eval shellspec_syntax_dispatch modifier ${1+'"$@"'}
}
