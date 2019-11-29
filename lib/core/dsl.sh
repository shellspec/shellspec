#shellcheck shell=sh disable=SC2004

SHELLSPEC_DESCRIPTION=''
SHELLSPEC_PATH_ALIAS=:
SHELLSPEC_INTERCEPTOR='|'
SHELLSPEC_SHELL_OPTIONS=''

# to suppress shellcheck SC2034
: "${SHELLSPEC_EXPECTATION:-} ${SHELLSPEC_EVALUATION:-}"
: "${SHELLSPEC_SKIP_REASON:-} ${SHELLSPEC_CONDITIONAL_SKIP:-}"
: "${SHELLSPEC_SPECFILE:-} ${SHELLSPEC_SPEC_NO:-} ${SHELLSPEC_LINENO:-}"

shellspec_metadata() {
  if [ "${1:-}" ]; then
    shellspec_output METADATA
  fi
}

shellspec_finished() {
  if [ "${1:-}" ]; then
    shellspec_output FINISHED
  else
    shellspec_putsn
  fi
}

shellspec_yield() {
  case $# in
    0) "shellspec_yield$SHELLSPEC_BLOCK_NO" ;;
    *) "shellspec_yield$SHELLSPEC_BLOCK_NO" "$@" ;;
  esac
  # shellcheck disable=SC2034
  SHELLSPEC_LINENO=''
}

shellspec_begin() {
  SHELLSPEC_SPECFILE=$1 SHELLSPEC_SPEC_NO=$2
  shellspec_output BEGIN
}

shellspec_perform() {
  SHELLSPEC_ENABLED=$1 SHELLSPEC_FILTER=$2
}

shellspec_end() {
  # shellcheck disable=SC2034
  SHELLSPEC_EXAMPLE_COUNT=${1:-}
  shellspec_output END
}

shellspec_description() {
  set -- "${2:-<$1:$SHELLSPEC_LINENO_BEGIN-$SHELLSPEC_LINENO_END>}"
  SHELLSPEC_DESCRIPTION="${SHELLSPEC_DESCRIPTION}$1"
}

shellspec_example_group() {
  shellspec_description "example_group" "${1:-}${1:+$SHELLSPEC_VT}"
  shellspec_yield
  shellspec_call_after_hooks ALL
}

shellspec_example_block() {
  if [ "${SHELLSPEC_PARAMETER_NO:-}" ]; then
    shellspec_parameters 1
  else
    "shellspec_example$SHELLSPEC_BLOCK_NO"
  fi
}

shellspec_parameters() {
  "shellspec_parameters$1"
  [ "$1" -eq "$SHELLSPEC_PARAMETER_NO" ] && return 0
  shellspec_parameters "$(($1 + 1))"
}

shellspec_parameterized_example() {
  ( case $# in
      0) "shellspec_example$SHELLSPEC_BLOCK_NO" ;;
      *) "shellspec_example$SHELLSPEC_BLOCK_NO" "$@" ;;
    esac
  )
  SHELLSPEC_EXAMPLE_NO=$(($SHELLSPEC_EXAMPLE_NO + 1))
}

shellspec_example() {
  shellspec_description "example" "${1:-}"
  if [ $# -gt 0 ]; then
    while shift && [ $# -gt 0 ]; do
      [ "$1" = "--" ] && shift && break
    done
  fi

  if [ "$SHELLSPEC_ENABLED" ] && [ "$SHELLSPEC_FILTER" ]; then
    if [ "$SHELLSPEC_DRYRUN" ]; then
      shellspec_output EXAMPLE
      shellspec_output SUCCEEDED
    else
      shellspec_call_before_hooks ALL
      shellspec_mark_executed_group "$SHELLSPEC_GROUP_ID"
      shellspec_profile_start
      case $- in
        *e*)
          set +e
          ( set -e
            case $# in
              0) shellspec_invoke_example ;;
              *) shellspec_invoke_example "$@" ;;
            esac
          )
          set -e -- $?
          ;;
        *)
          ( set -e
            case $# in
              0) shellspec_invoke_example ;;
              *) shellspec_invoke_example "$@" ;;
            esac
          )
          set -- $?
      esac
      if [ "$1" -ne 0 ]; then
        shellspec_output ABORTED "$1"
        shellspec_output FAILED
      fi
      shellspec_profile_end
    fi
  fi
}

shellspec_invoke_example() {
  shellspec_output EXAMPLE

  shellspec_on NOT_IMPLEMENTED
  shellspec_off FAILED WARNED EXPECTATION
  shellspec_off UNHANDLED_STATUS UNHANDLED_STDOUT UNHANDLED_STDERR

  # Output SKIP message if skipped in outer group.
  shellspec_output_if SKIP || {
    "${SHELLSPEC_SHELL_OPTION:-eval}" "${SHELLSPEC_SHELL_OPTIONS:-:}"
    if ! shellspec_call_before_hooks EACH; then
      SHELLSPEC_LINENO=$SHELLSPEC_LINENO_BEGIN-$SHELLSPEC_LINENO_END
      shellspec_output FAILED_BEFORE_EACH_HOOK
      shellspec_output FAILED
      return 0
    fi
    shellspec_output_if PENDING ||:
    case $# in
      0) shellspec_yield ;;
      *) shellspec_yield "$@" ;;
    esac
    if ! shellspec_call_after_hooks EACH; then
      SHELLSPEC_LINENO=$SHELLSPEC_LINENO_BEGIN-$SHELLSPEC_LINENO_END
      shellspec_output FAILED_AFTER_EACH_HOOK
      shellspec_output FAILED
      return 0
    fi
  }

  shellspec_if SKIP && shellspec_unless FAILED && {
    shellspec_output SKIPPED && return 0
  }

  shellspec_output_if NOT_IMPLEMENTED && shellspec_output TODO && return 0
  shellspec_output_unless EXPECTATION && shellspec_on WARNED
  shellspec_output_if UNHANDLED_STATUS && shellspec_on WARNED
  shellspec_output_if UNHANDLED_STDOUT && shellspec_on WARNED
  shellspec_output_if UNHANDLED_STDERR && shellspec_on WARNED

  shellspec_if PENDING && {
    shellspec_if FAILED && shellspec_output TODO && return 0
    [ "$SHELLSPEC_WARNING_AS_FAILURE" ] && shellspec_if WARNED && {
      shellspec_output TODO && return 0
    }
    shellspec_output FIXED && return 0
  }

  shellspec_output_if FAILED && return 0
  shellspec_output_if WARNED || shellspec_output SUCCEEDED
}

shellspec_statement() {
  shellspec_off SYNTAX_ERROR
  shellspec_if SKIP && return 0
  # shellcheck disable=SC2145
  "shellspec_$@"
  shellspec_if SYNTAX_ERROR && shellspec_on FAILED
  return 0
}

shellspec_when() {
  eval shellspec_join SHELLSPEC_EVALUATION ${1+'"$@"'}
  shellspec_off NOT_IMPLEMENTED

  shellspec_if EVALUATION && {
    shellspec_output SYNTAX_ERROR_EVALUATION \
      "Evaluation has already been executed"
    shellspec_on FAILED
    return 0
  }
  shellspec_on EVALUATION

  shellspec_if EXPECTATION && {
    shellspec_output SYNTAX_ERROR_EVALUATION "Expectation has already been executed"
    shellspec_on FAILED
    return 0
  }

  if [ $# -eq 0 ]; then
    shellspec_output SYNTAX_ERROR_EVALUATION "Missing evaluation type"
    shellspec_on FAILED
    return 0
  fi

  if [ $# -eq 1 ]; then
    shellspec_output SYNTAX_ERROR_EVALUATION "Missing evaluation"
    shellspec_on FAILED
    return 0
  fi

  shellspec_statement_evaluation "$@"
  shellspec_output EVALUATION
}

shellspec_around_call() {
  shellspec_call_before_hooks CALL || {
    set -- $?
    echo "BeforeCall hook '$SHELLSPEC_HOOK' failed" >&2
    return "$1"
  }
  "$@"
  set -- $?
  [ "$1" -ne 0 ] && return "$1"
  shellspec_call_after_hooks CALL || {
    set -- $?
    echo "AfterCall hook '$SHELLSPEC_HOOK' failed" >&2
    return "$1"
  }
  return "$1"
}

shellspec_around_run() {
  shellspec_call_before_hooks RUN || {
    set -- $?
    echo "BeforeRun hook '$SHELLSPEC_HOOK' failed" >&2
    return "$1"
  }
  "$@"
  set -- $?
  [ "$1" -ne 0 ] && return "$1"
  shellspec_call_after_hooks RUN || {
    set -- $?
    echo "AfterRun hook '$SHELLSPEC_HOOK' failed" >&2
    return "$1"
  }
  return "$1"
}

shellspec_the() {
  eval shellspec_join SHELLSPEC_EXPECTATION The ${1+'"$@"'}
  shellspec_off NOT_IMPLEMENTED
  shellspec_on EXPECTATION

  if [ $# -eq 0 ]; then
    shellspec_output SYNTAX_ERROR_EXPECTATION "Missing expectation"
    shellspec_on FAILED
    return 0
  fi

  shellspec_statement_preposition "$@"
}

shellspec_proxy shellspec_before_all "shellspec_register_before_hook ALL"
shellspec_proxy shellspec_after_all "shellspec_register_after_hook ALL"

shellspec_proxy shellspec_before "shellspec_register_before_hook EACH"
shellspec_proxy shellspec_after "shellspec_register_after_hook EACH"

shellspec_proxy shellspec_before_call "shellspec_register_before_hook CALL"
shellspec_proxy shellspec_after_call "shellspec_register_after_hook CALL"

shellspec_proxy shellspec_before_run "shellspec_register_before_hook RUN"
shellspec_proxy shellspec_after_run "shellspec_register_after_hook RUN"

shellspec_path() {
  while [ $# -gt 0 ]; do
    SHELLSPEC_PATH_ALIAS="${SHELLSPEC_PATH_ALIAS}$1:"
    shift
  done
}

shellspec_skip() {
  # Do nothing if already skipped by current example or example group
  shellspec_if SKIP && return 0
  # shellcheck disable=SC2034
  SHELLSPEC_SKIP_ID=$1
  shift

  if [ "${1:-}" = if ]; then
    [ $# -ge 3 ] || return 0
    SHELLSPEC_SKIP_REASON=$2
    shift 2
    ( "$@" ) || return 0
  else
    SHELLSPEC_SKIP_REASON=${1:-}
  fi

  # Output SKIP message if within the example group
  [ "${SHELLSPEC_EXAMPLE_NO:-}" ] && shellspec_output SKIP
  shellspec_on SKIP
}

shellspec_pending() {
  shellspec_if SKIP && return 0
  # shellcheck disable=SC2034
  SHELLSPEC_PENDING_REASON="${1:-}"
  # Output PENDING message if within the example group
  [ "${SHELLSPEC_EXAMPLE_NO:-}" ] && shellspec_output PENDING
  # if already failed, can not pending
  shellspec_if FAILED || shellspec_on PENDING
}

shellspec_logger() {
  sleep 0
  shellspec_putsn "$@" >"$SHELLSPEC_LOGFILE"
}

shellspec_intercept() {
  while [ $# -gt 0 ]; do
    case $1 in
    *: ) SHELLSPEC_INTERCEPTOR="${SHELLSPEC_INTERCEPTOR}$1${1%:}|" ;;
    *:*) SHELLSPEC_INTERCEPTOR="${SHELLSPEC_INTERCEPTOR}$1|" ;;
    *  ) SHELLSPEC_INTERCEPTOR="${SHELLSPEC_INTERCEPTOR}$1:__$1__|" ;;
    esac
    shift
  done
}

shellspec_set() {
  while [ $# -gt 0 ]; do
    shellspec_append_shell_option SHELLSPEC_SHELL_OPTIONS "$1"
    shift
  done
}

shellspec_marker() {
  shellspec_putsn "${SHELLSPEC_SYN}shellspec_marker:$1 $2" >&2
}

shellspec_abort() {
  shellspec_putsn "${2:-}" >&2
  [ "${3:-}" ] && shellspec_putsn "${3:-}" >&2
  exit "${1:-1}"
}
