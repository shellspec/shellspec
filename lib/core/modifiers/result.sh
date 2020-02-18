#shellcheck shell=sh

shellspec_syntax 'shellspec_modifier_result'

SHELLSPEC_RESULT_STDOUT_FILE="$SHELLSPEC_TMPBASE/$$.result.stdout"
SHELLSPEC_RESULT_STDERR_FILE="$SHELLSPEC_TMPBASE/$$.result.stderr"

shellspec_modifier_result() {
  if [ "${SHELLSPEC_SUBJECT+x}" ]; then
    if ! shellspec_is_function "$SHELLSPEC_SUBJECT"; then
      shellspec_output SYNTAX_ERROR "'$SHELLSPEC_SUBJECT' is not function name"
      return 1
    fi

    shellspec_off UNHANDLED_STDOUT UNHANDLED_STDERR UNHANDLED_STATUS
    if shellspec_modifier_result_invoke; then
      shellspec_readfile SHELLSPEC_SUBJECT "$SHELLSPEC_RESULT_STDOUT_FILE"
      shellspec_chomp SHELLSPEC_SUBJECT
    else
      unset SHELLSPEC_SUBJECT ||:
    fi
    [ -s "$SHELLSPEC_RESULT_STDERR_FILE" ] && return 1
  else
    unset SHELLSPEC_SUBJECT ||:
  fi

  eval shellspec_syntax_dispatch modifier ${1+'"$@"'}
}

shellspec_modifier_result_invoke() {
  set -- "$SHELLSPEC_SUBJECT"
  "$@" "${SHELLSPEC_STDOUT:-}" "${SHELLSPEC_STDERR:-}" "${SHELLSPEC_STATUS:-}" \
    >"$SHELLSPEC_RESULT_STDOUT_FILE" 2>"$SHELLSPEC_RESULT_STDERR_FILE"
  set -- "$?"
  if [ -s "$SHELLSPEC_RESULT_STDERR_FILE" ]; then
    shellspec_output RESULT_ERROR "$1" "$SHELLSPEC_RESULT_STDERR_FILE"
  fi
  return "$1"
}
