#shellcheck shell=sh

shellspec_syntax 'shellspec_modifier_result'

shellspec_modifier_result() {
  if [ "${SHELLSPEC_SUBJECT+x}" ]; then
    if ! SHELLSPEC_SUBJECT=$($SHELLSPEC_SUBJECT 2>&1); then
      unset SHELLSPEC_SUBJECT ||:
    fi
  else
    unset SHELLSPEC_SUBJECT ||:
  fi

  eval shellspec_syntax_dispatch modifier ${1+'"$@"'}
}
