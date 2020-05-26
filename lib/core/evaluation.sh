#shellcheck shell=sh

SHELLSPEC_STDIN_DEV=/dev/null
(: < /dev/tty) 2>/dev/null && SHELLSPEC_STDIN_DEV=/dev/tty

shellspec_syntax 'shellspec_evaluation_call'
shellspec_syntax 'shellspec_evaluation_run'

shellspec_proxy 'shellspec_evaluation' 'shellspec_syntax_dispatch evaluation'

shellspec_invoke_data() {
  if [ "${SHELLSPEC_DATA:-}" ]; then
    case $# in
      0) shellspec_data > "$SHELLSPEC_STDIN_FILE" ;;
      *) shellspec_data "$@" > "$SHELLSPEC_STDIN_FILE" ;;
    esac
  fi
}

shellspec_evaluation_call() {
  set "$SHELLSPEC_ERREXIT"
  "${SHELLSPEC_SHELL_OPTION:-eval}" "${SHELLSPEC_SHELL_OPTIONS:-:}"
  set +e
  shellspec_evaluation_call_data shellspec_evaluation_call_function "$@"
  set -e -- $?
  shellspec_evaluation_cleanup "$1"
}

shellspec_evaluation_call_data() {
  if [ ! "${SHELLSPEC_DATA:-}" ]; then
    shellspec_around_call "$@" < "$SHELLSPEC_STDIN_DEV" \
      >"$SHELLSPEC_STDOUT_FILE" 2>"$SHELLSPEC_STDERR_FILE" &&:
  else
    shellspec_around_call "$@" < "$SHELLSPEC_STDIN_FILE" \
      >"$SHELLSPEC_STDOUT_FILE" 2>"$SHELLSPEC_STDERR_FILE" &&:
  fi
}

shellspec_evaluation_run() {
  set "$SHELLSPEC_ERREXIT"
  "${SHELLSPEC_SHELL_OPTION:-eval}" "${SHELLSPEC_SHELL_OPTIONS:-:}"
  case $- in
    *e*) set +e; shellspec_evaluation_run_subshell -e "$@"; ;;
    *) shellspec_evaluation_run_subshell +e "$@"; ;;
  esac
  set -e -- $?
  shellspec_evaluation_cleanup "$1"
}

shellspec_evaluation_run_subshell() {
  ( set "$1"; shift
    shellspec_evaluation_run_data "$@"
  )
}

# Workaround for #40 in contrib/bugs.sh
# ( ... ) not return exit status
shellspec_evaluation_run_subshell_workaround() {
  case $1 in (*e*) set +e; esac
  (set -e; foo() { return 2; }; foo) 2>/dev/null
  if [ $? -eq 1 ]; then
    shellspec_evaluation_run_subshell() {
      #shellcheck disable=SC2034
      SHELLSPEC_DUMMY=$( set "$1"; shift; shellspec_evaluation_run_data "$@" )
    }
  fi
  case $1 in (*e*) set -e; esac
}
shellspec_evaluation_run_subshell_workaround "$-"

shellspec_evaluation_run_data() {
  if [ ! "${SHELLSPEC_DATA:-}" ]; then
    shellspec_evaluation_run_trap_exit_status "$@" < "$SHELLSPEC_STDIN_DEV" \
      >"$SHELLSPEC_STDOUT_FILE" 2>"$SHELLSPEC_STDERR_FILE"
  else
    shellspec_evaluation_run_trap_exit_status "$@" < "$SHELLSPEC_STDIN_FILE" \
      >"$SHELLSPEC_STDOUT_FILE" 2>"$SHELLSPEC_STDERR_FILE"
  fi
}

if [ "${ZSH_VERSION:-}" ] && (exit 1); then
  shellspec_evaluation_run_trap_exit_status() {
    SHELLSPEC_ZSH_EXIT_CODES="$SHELLSPEC_TMPBASE/$$.exit_codes.$SHELLSPEC_SPEC_NO.$SHELLSPEC_EXAMPLE_NO"
    : > "$SHELLSPEC_ZSH_EXIT_CODES"

    case $- in
      *e*) set +e; set -- -e "$@" ;;
      *) set -- +e "$@" ;;
    esac
    ( set "$1"; shift
      # "unset status" causes an error and forces exit instead of "exit"
      # status variable is special variable, can not unset in zsh
      SHELLSPEC_EVAL="
        exit() { \
          echo -n \"\$1 \" >> \"\$SHELLSPEC_ZSH_EXIT_CODES\"; \
          { unset status; } 2>/dev/null \
        }
      "
      eval "$SHELLSPEC_EVAL"
      shellspec_around_run shellspec_evaluation_run_instruction "$@"
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
  shellspec_evaluation_run_trap_exit_status() {
    shellspec_around_run shellspec_evaluation_run_instruction "$@"
  }
fi

shellspec_evaluation_run_instruction() {
  case $1 in
    script) shift; shellspec_evaluation_run_script "$@" ;;
    command) shift; shellspec_evaluation_run_command "$@" ;;
    source) shift; shellspec_evaluation_run_source "$@" ;;
    *) shellspec_evaluation_call_function "$@" ;;
  esac
}

shellspec_shebang_arguments() {
  read -r line
  case $line in (\#!/usr/bin/env\ * | \#!/bin/env\ *)
    shellspec_trim line "${line#* }"
    line="#!$line"
  esac
  case $line in (\#!*)
    shellspec_trim line "$line"
    case $line in (*\ *)
      shellspec_trim line "${line#* }"
      shellspec_putsn "$line"
    esac
  esac
}

shellspec_evaluation_call_function() {
  shellspec_coverage_start
  "$@"
  set -- "$?"
  shellspec_coverage_stop
  return "$1"
}

shellspec_evaluation_run_script() {
  if [ ! -e "$1" ]; then
    eval "$SHELLSPEC_SHELL \"\$@\""
  elif [ ! -x "$1" ]; then
    # Execute non-executable file always fails. This is getting error message.
    command "$@" &
    wait $! # wait is workaround for ksh 93r. sometimes fail to get stderr.
  else
    if [ "$SHELLSPEC_SHEBANG_MULTIARG" ]; then
      IFS=" $IFS"
      # shellcheck disable=SC2046
      set -- $(shellspec_shebang_arguments < "$1") "$@"
      IFS=${IFS# }
    else
      set -- "$(shellspec_shebang_arguments < "$1")" "$@"
      [ "$1" ] || shift
    fi
    ( shellspec_coverage_env
      eval "$SHELLSPEC_SHELL $SHELLSPEC_COVERAGE_SHELL_OPTIONS \"\$@\""
    )
  fi
}

shellspec_evaluation_run_command() {
  set -- "$(shellspec_which "$1")" "$@" &&:
  if [ ! "$1" ]; then
    shellspec_abort 127 "$SHELLSPEC_SHELL: $SHELLSPEC_LINENO: $2: not found"
  fi
  case $# in
    2) set -- "$1" ;;
    *) eval "shift 2; set -- \"$1\" \"\$@\"" ;;
  esac
  "$@"
}

shellspec_evaluation_run_source() {
  test() {
    case $# in
      0) test() { case $# in (0) false ;; (*) [ "$@" ]; esac; } ;;
      *) [ "$@" ] ;;
    esac
  }
  __() { shellspec_interceptor "$@"; }
  shellspec_coverage_start
  eval "shift; . \"$1\""
  set -- "$?"
  shellspec_coverage_stop
  return "$1"
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
