#shellcheck shell=sh

SHELLSPEC_STDOUT_FILE="$SHELLSPEC_TMPBASE/$$.stdout"
SHELLSPEC_STDERR_FILE="$SHELLSPEC_TMPBASE/$$.stderr"

shellspec_syntax 'shellspec_evaluation_call'
shellspec_syntax 'shellspec_evaluation_run'
shellspec_syntax 'shellspec_evaluation_invoke'

shellspec_proxy 'shellspec_evaluation' 'shellspec_syntax_dispatch evaluation'

shellspec_evaluation_call() {
  shellspec_syntax_param count [ $# -gt 0 ] || return 0
  "$@" >"$SHELLSPEC_STDOUT_FILE" 2>"$SHELLSPEC_STDERR_FILE" &&:
  shellspec_evaluation_cleanup $?
}

shellspec_evaluation_run() {
  command "$@" >"$SHELLSPEC_STDOUT_FILE" 2>"$SHELLSPEC_STDERR_FILE" &&:
  shellspec_evaluation_cleanup $?
}

shellspec_evaluation_invoke() {
  ( "$@" ) >"$SHELLSPEC_STDOUT_FILE" 2>"$SHELLSPEC_STDERR_FILE" &&:
  shellspec_evaluation_cleanup $?
}

shellspec_evaluation_cleanup() {
  SHELLSPEC_EXIT_STATUS=$1
  shellspec_readfile SHELLSPEC_STDOUT "$SHELLSPEC_STDOUT_FILE"
  shellspec_readfile SHELLSPEC_STDERR "$SHELLSPEC_STDERR_FILE"
  shellspec_toggle UNHANDLED_STATUS [ "$SHELLSPEC_EXIT_STATUS" -ne 0 ]
  shellspec_toggle UNHANDLED_STDOUT [ "$SHELLSPEC_STDOUT" ]
  shellspec_toggle UNHANDLED_STDERR [ "$SHELLSPEC_STDERR" ]
}
