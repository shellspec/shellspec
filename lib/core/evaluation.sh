#shellcheck shell=sh

SHELLSPEC_STDIN_FILE="$SHELLSPEC_TMPBASE/$$.stdin"
SHELLSPEC_STDOUT_FILE="$SHELLSPEC_TMPBASE/$$.stdout"
SHELLSPEC_STDERR_FILE="$SHELLSPEC_TMPBASE/$$.stderr"

shellspec_syntax 'shellspec_evaluation_call'
shellspec_syntax 'shellspec_evaluation_run'
shellspec_syntax 'shellspec_evaluation_invoke'
shellspec_syntax 'shellspec_evaluation_execute'

shellspec_proxy 'shellspec_evaluation' 'shellspec_syntax_dispatch evaluation'

shellspec_evaluation_call() {
  if [ ! "${SHELLSPEC_DATA:-}" ]; then
    shellspec_evaluation_call_ "$@"
  else
    shellspec_data > "$SHELLSPEC_STDIN_FILE"
    shellspec_evaluation_call_ "$@" < "$SHELLSPEC_STDIN_FILE"
  fi >"$SHELLSPEC_STDOUT_FILE" 2>"$SHELLSPEC_STDERR_FILE" &&:
  shellspec_evaluation_cleanup $?
}

shellspec_evaluation_call_() {
  shellspec_around_call shellspec_evaluation_call__ "$@"
}

shellspec_evaluation_call__() {
  case $1 in
    command) shift; command "$@" ;;
    *) "$@" ;;
  esac
}

shellspec_evaluation_run() {
  case $- in
    *e*) set +e; shellspec_evaluation_run_ -e "$@"; set -e -- $? ;;
    *) shellspec_evaluation_run_ +e "$@"; set -- $? ;;
  esac
  shellspec_evaluation_cleanup "$1"
}

if [ "${SHELLSPEC_SHELL_TYPE#p}" = "bosh" ]; then
  shellspec_evaluation_run_() {
    ( set "$1"; shift; shellspec_evaluation_run__ "$@" )
  }
else
  # Workaround for #40 in contrib/bugs.sh
  # ( ... ) not return exit status
  shellspec_evaluation_run_() {
    #shellcheck disable=SC2034
    SHELLSPEC_DUMMY=$( set "$1"; shift; shellspec_evaluation_run__ "$@" )
  }
fi

shellspec_evaluation_run__() {
  if [ ! "${SHELLSPEC_DATA:-}" ]; then
    shellspec_evaluation_run___ "$@"
  else
    shellspec_data > "$SHELLSPEC_STDIN_FILE"
    shellspec_evaluation_run___ "$@" < "$SHELLSPEC_STDIN_FILE"
  fi >"$SHELLSPEC_STDOUT_FILE" 2>"$SHELLSPEC_STDERR_FILE"
}

if [ "${ZSH_VERSION:-}" ] && (exit 1); then
  shellspec_evaluation_run___() {
    SHELLSPEC_ZSH_EXIT_CODES="$SHELLSPEC_TMPBASE/$$.exit_codes"
    SHELLSPEC_ZSH_EXIT_CODES="$SHELLSPEC_ZSH_EXIT_CODES.$SHELLSPEC_SPEC_NO"
    SHELLSPEC_ZSH_EXIT_CODES="$SHELLSPEC_ZSH_EXIT_CODES.$SHELLSPEC_EXAMPLE_NO"
    : > "$SHELLSPEC_ZSH_EXIT_CODES"
    set +e
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
      shellspec_evaluation_run____ "$@"
    )
    (
      error=$?
      if [ -s "$SHELLSPEC_ZSH_EXIT_CODES" ]; then
        read -r ecs < "$SHELLSPEC_ZSH_EXIT_CODES" ||:
        ecs=${ecs% } && ecs=${ecs% *} && error=${ecs##* }
      fi
      return "$error"
    )
  }
else
  shellspec_evaluation_run___() { shellspec_evaluation_run____ "$@"; }
fi

shellspec_evaluation_run____() {
  shellspec_around_run shellspec_evaluation_run_____ "$@"
}

shellspec_evaluation_run_____() {
  case $1 in
    command) shift; command "$@" ;;
    source) shift; shellspec_evaluation_execute_ "$@" ;;
    *) "$@" ;;
  esac
}

shellspec_around_invoke() { "$@"; }

shellspec_evaluation_invoke() {
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
    SHELLSPEC_ZSH_EXIT_CODES="$SHELLSPEC_TMPBASE/$$.exit_codes"
    SHELLSPEC_ZSH_EXIT_CODES="$SHELLSPEC_ZSH_EXIT_CODES.$SHELLSPEC_SPEC_NO"
    SHELLSPEC_ZSH_EXIT_CODES="$SHELLSPEC_ZSH_EXIT_CODES.$SHELLSPEC_EXAMPLE_NO"
    : > "$SHELLSPEC_ZSH_EXIT_CODES"
    set +e
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
        read -r ecs < "$SHELLSPEC_ZSH_EXIT_CODES" ||:
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

shellspec_evaluation_execute() {
  shellspec_evaluation_run shellspec_evaluation_execute_ "$@"
}

shellspec_evaluation_execute_() {
  test() {
    if [ $# -eq 0 ]; then
      test() { eval [ ${1+'"$@"'} ]; }
    else
      eval [ ${1+'"$@"'} ]
    fi
  }
  __() { shellspec_interceptor "$@"; }
  eval "shift; . $1"
}

shellspec_interceptor() {
  eval "[ \"\${$#}\" = __ ] &&:" || return 0
  set -- "$@" "$SHELLSPEC_EM"
  until [ "$2" = "$SHELLSPEC_EM" ]; do
    set -- "$@" "$1"
    shift
  done
  shift 2
  case $SHELLSPEC_INTERCEPTOR in (*\|$1:*)
    eval "shift; set -- \"${SHELLSPEC_INTERCEPTOR##*\|$1:}\" ${2:+\"\$@\"}"
    eval "shift; set -- \"${1%%\|*}\" ${2:+\"\$@\"}"
    "$@"
  esac
}

shellspec_evaluation_cleanup() {
  SHELLSPEC_STATUS=$1
  shellspec_readfile SHELLSPEC_STDOUT "$SHELLSPEC_STDOUT_FILE"
  shellspec_readfile SHELLSPEC_STDERR "$SHELLSPEC_STDERR_FILE"
  shellspec_toggle UNHANDLED_STATUS [ "$SHELLSPEC_STATUS" -ne 0 ]
  shellspec_toggle UNHANDLED_STDOUT [ "$SHELLSPEC_STDOUT" ]
  shellspec_toggle UNHANDLED_STDERR [ "$SHELLSPEC_STDERR" ]
}
