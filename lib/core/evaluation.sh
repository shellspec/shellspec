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
  if [ "${SHELLSPEC_DATA:-}" ]; then
    set -- shellspec_evaluation_with_data "$@"
  fi
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
  if [ "${SHELLSPEC_DATA:-}" ]; then
    set -- shellspec_evaluation_with_data "$@"
  fi
  shellspec_evaluation_invoke_wrapper "$@" >"$SHELLSPEC_STDOUT_FILE" 2>"$SHELLSPEC_STDERR_FILE" &&:
  shellspec_evaluation_cleanup $?
}

shellspec_evaluation_invoke_wrapper() {
  ( shellspec_around_invoke "$@" )
}

if [ "${ZSH_VERSION:-}" ] && (exit 1); then
  # Ugly workaround for can not get exit code from subshell on zsh 4.2.5.
  # Implemented for "execute evaluation", but discontinue support
  # if any more problems are found.
  shellspec_evaluation_invoke_wrapper() {
    ( : ) & # Use $! as a unique ID
    SHELLSPEC_ZSH_EXIT_CODES="$SHELLSPEC_TMPBASE/$$.exit_codes.$!"
    : > "$SHELLSPEC_ZSH_EXIT_CODES"
    (
      # "unset status" causes an error and forces exit instead of "exit"
      # status variable is special variable, can not unset in zsh
      SHELLSPEC_EVAL="
        exit() { \
          echo -n \"\$1 \" >> \"\$SHELLSPEC_ZSH_EXIT_CODES\"; \
          { unset status; } 2>/dev/null \
        }
      "
      eval "$SHELLSPEC_EVAL"
      shellspec_around_invoke "$@"
    )
    (
      error=$?
      if [ -s "$SHELLSPEC_ZSH_EXIT_CODES" ]; then
        read -r ecs < "$SHELLSPEC_ZSH_EXIT_CODES"
        ecs=${ecs% } && ecs=${ecs% *} && error=${ecs##* }
      fi
      return "$error"
    )
  }
fi

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
