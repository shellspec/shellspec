#shellcheck shell=sh

SHELLSPEC_STDIN_FILE="$SHELLSPEC_TMPBASE/$$.stdin"
SHELLSPEC_STDOUT_FILE="$SHELLSPEC_TMPBASE/$$.stdout"
SHELLSPEC_STDERR_FILE="$SHELLSPEC_TMPBASE/$$.stderr"

shellspec_syntax 'shellspec_evaluation_call'
shellspec_syntax 'shellspec_evaluation_run'
shellspec_syntax 'shellspec_evaluation_invoke'

shellspec_proxy 'shellspec_evaluation' 'shellspec_syntax_dispatch evaluation'

shellspec_evaluation_call() {
  if ! shellspec_is funcname "$1"; then
    eval "shellspec_evaluation_eval() { $1; }"
    shift
    eval set -- shellspec_evaluation_eval ${1+'"$@"'}
  fi
  [ ! "${SHELLSPEC_DATA:-}" ] || set -- shellspec_evaluation_with_data "$@"
  "$@" >"$SHELLSPEC_STDOUT_FILE" 2>"$SHELLSPEC_STDERR_FILE" &&:
  shellspec_evaluation_cleanup $?
}

shellspec_evaluation_run() {
  ( if [ "${SHELLSPEC_DATA:-}" ]; then
      shellspec_data > "$SHELLSPEC_STDIN_FILE"
      command "$@" < "$SHELLSPEC_STDIN_FILE"
    else
      command "$@"
    fi
  ) >"$SHELLSPEC_STDOUT_FILE" 2>"$SHELLSPEC_STDERR_FILE" &&:
  shellspec_evaluation_cleanup $?
}

shellspec_around_invoke() { "$@"; }

shellspec_evaluation_invoke() {
  if ! shellspec_is funcname "$1"; then
    eval "shellspec_evaluation_eval() { $1; }"
    shift
    eval set -- shellspec_evaluation_eval ${1+'"$@"'}
  fi
  [ ! "${SHELLSPEC_DATA:-}" ] || set -- shellspec_evaluation_with_data "$@"
  ( shellspec_around_invoke "$@" ) >"$SHELLSPEC_STDOUT_FILE" 2>"$SHELLSPEC_STDERR_FILE" &&:
  shellspec_evaluation_cleanup $?
}

shellspec_evaluation_with_data() {
  shellspec_data > "$SHELLSPEC_STDIN_FILE"
  "$@" < "$SHELLSPEC_STDIN_FILE"
}

shellspec_evaluation_cleanup() {
  SHELLSPEC_STATUS=$1
  shellspec_readfile SHELLSPEC_STDOUT "$SHELLSPEC_STDOUT_FILE"
  shellspec_readfile SHELLSPEC_STDERR "$SHELLSPEC_STDERR_FILE"
  shellspec_toggle UNHANDLED_STATUS [ "$SHELLSPEC_STATUS" -ne 0 ]
  shellspec_toggle UNHANDLED_STDOUT [ "$SHELLSPEC_STDOUT" ]
  shellspec_toggle UNHANDLED_STDERR [ "$SHELLSPEC_STDERR" ]
}
