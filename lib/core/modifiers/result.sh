#shellcheck shell=sh

shellspec_syntax 'shellspec_modifier_result'

shellspec_modifier_result() {
  SHELLSPEC_RESULT_STDOUT_FILE="$SHELLSPEC_WORKDIR/result.stdout"
  SHELLSPEC_RESULT_STDERR_FILE="$SHELLSPEC_WORKDIR/result.stderr"

  # shellcheck disable=SC2034
  SHELLSPEC_META='text'
  if [ "${SHELLSPEC_SUBJECT+x}" ]; then
    if ! shellspec_is_function "$SHELLSPEC_SUBJECT"; then
      shellspec_output SYNTAX_ERROR "'$SHELLSPEC_SUBJECT' is not function name"
      return 1
    fi

    shellspec_off UNHANDLED_STDOUT UNHANDLED_STDERR UNHANDLED_STATUS
    if shellspec_modifier_result_invoke; then
      shellspec_capturefile SHELLSPEC_SUBJECT "$SHELLSPEC_RESULT_STDOUT_FILE"
    else
      unset SHELLSPEC_SUBJECT ||:
    fi
  else
    unset SHELLSPEC_SUBJECT ||:
  fi

  eval shellspec_syntax_dispatch modifier ${1+'"$@"'}
}

shellspec_modifier_result_invoke() {
  set -- "${SHELLSPEC_STDOUT:-}" "${SHELLSPEC_STDERR:-}" "${SHELLSPEC_STATUS:-}"
  if [ -e "$SHELLSPEC_STDOUT_FILE" ]; then
    ( "$SHELLSPEC_SUBJECT" "$@" < "$SHELLSPEC_STDOUT_FILE" )
  else
    ( "$SHELLSPEC_SUBJECT" "$@" < /dev/null )
  fi >"$SHELLSPEC_RESULT_STDOUT_FILE" 2>"$SHELLSPEC_RESULT_STDERR_FILE" &&:
  set -- "$?"
  [ -s "$SHELLSPEC_RESULT_STDERR_FILE" ] || return "$1"
  shellspec_output RESULT_WARN "$1" "$SHELLSPEC_RESULT_STDERR_FILE"
  shellspec_on WARNED
  return 1
}
