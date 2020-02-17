#shellcheck shell=sh

shellspec_syntax 'shellspec_modifier_result'

shellspec_modifier_result() {
  if [ "${SHELLSPEC_SUBJECT+x}" ]; then
    if ! shellspec_is_function "$SHELLSPEC_SUBJECT"; then
      shellspec_output SYNTAX_ERROR "'$SHELLSPEC_SUBJECT' is not function name"
      return 0
    fi

    shellspec_off UNHANDLED_STDOUT UNHANDLED_STDERR UNHANDLED_STATUS
    if ! SHELLSPEC_SUBJECT=$(shellspec_modifier_result_invoke 2>&1); then
      unset SHELLSPEC_SUBJECT ||:
    fi
  else
    unset SHELLSPEC_SUBJECT ||:
  fi

  eval shellspec_syntax_dispatch modifier ${1+'"$@"'}
}

shellspec_modifier_result_invoke() {
  set -- "$SHELLSPEC_SUBJECT"
  "$@" "${SHELLSPEC_STDOUT:-}" "${SHELLSPEC_STDERR:-}" "${SHELLSPEC_STATUS:-}"
}
