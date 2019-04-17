#shellcheck shell=sh

SHELLSPEC_DESCRIPTION=''
SHELLSPEC_PATH_ALIAS=:

# to suppress shellcheck SC2034
: "${SHELLSPEC_EXPECTATION:-}" "${SHELLSPEC_EVALUATION:-}"
: "${SHELLSPEC_SKIP_REASON:-}" "${SHELLSPEC_CONDITIONAL_SKIP:-}"
: "${SHELLSPEC_LINENO:-}"

shellspec_metadata() { shellspec_output METADATA; }
shellspec_flush() { shellspec_output FLUSH; }

shellspec_yield() {
  "shellspec_yield$SHELLSPEC_BLOCK_NO"
  # shellcheck disable=SC2034
  SHELLSPEC_LINENO=''
}

shellspec_specfile() {
  case $1 in
    begin) shellspec_output SPECFILE_BEGIN ;;
    end)   shellspec_output SPECFILE_END ;;
  esac
}

shellspec_desc() {
  if [ "$2" ]; then
    SHELLSPEC_DESC=$2
  else
    SHELLSPEC_DESC="<$1:$SHELLSPEC_LINENO_BEGIN-$SHELLSPEC_LINENO_END>"
  fi

  if [ "$SHELLSPEC_DESCRIPTION" ]; then
    SHELLSPEC_DESCRIPTION="$SHELLSPEC_DESCRIPTION $SHELLSPEC_DESC"
  else
    SHELLSPEC_DESCRIPTION="$SHELLSPEC_DESC"
  fi
}

shellspec_example_group() {
  shellspec_desc "example group" "${1:-}"
  shellspec_output EXAMPLE_GROUP_BEGIN
  shellspec_yield
  shellspec_output EXAMPLE_GROUP_END
}

shellspec_example() {
  shellspec_desc "example" "${1:-}"
  shellspec_output EXAMPLE_BEGIN

  if [ "$SHELLSPEC_DRYRUN" ]; then
    shellspec_output SUCCEEDED
  else
    shellspec_invoke_example
  fi

  shellspec_output EXAMPLE_END
}

shellspec_invoke_example() {
  shellspec_on NOT_IMPLEMENTED
  shellspec_off FAILED WARNED
  shellspec_off UNHANDLED_STATUS UNHANDLED_STDOUT UNHANDLED_STDERR

  # Output SKIP message if skipped in outer group.
  shellspec_output_if SKIP || {
    if ! shellspec_call_before_hooks; then
      SHELLSPEC_LINENO=$SHELLSPEC_LINENO_BEGIN-$SHELLSPEC_LINENO_END
      shellspec_output FAILED_BEFORE_HOOK
      shellspec_output FAILED
      return
    fi
    shellspec_output_if PENDING ||:
    shellspec_yield
    if ! shellspec_call_after_hooks; then
      SHELLSPEC_LINENO=$SHELLSPEC_LINENO_BEGIN-$SHELLSPEC_LINENO_END
      shellspec_output FAILED_AFTER_HOOK
      shellspec_output FAILED
      return
    fi
  }

  shellspec_if SKIP && shellspec_output SKIPPED && return
  shellspec_output_if NOT_IMPLEMENTED && shellspec_output TODO && return
  shellspec_output_if UNHANDLED_STATUS && shellspec_on WARNED
  shellspec_output_if UNHANDLED_STDOUT && shellspec_on WARNED
  shellspec_output_if UNHANDLED_STDERR && shellspec_on WARNED

  shellspec_if PENDING && {
    shellspec_if FAILED && shellspec_output TODO && return
    shellspec_output FIXED && return
  }
  shellspec_output_if FAILED && return
  shellspec_output_if WARNED || shellspec_output SUCCEEDED
}

shellspec_statement() {
  shellspec_off SYNTAX_ERROR
  shellspec_if SKIP && return 0
  eval "shift; shellspec_$1 ${2+\"\$@\"}"
  shellspec_if SYNTAX_ERROR && shellspec_on FAILED
  return 0
}

shellspec_when() {
  SHELLSPEC_EVALUATION="When ${*:-}"
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
    shellspec_output SYNTAX_ERROR_EVALUATION "Missing evaluation"
    shellspec_on FAILED
    return 0
  fi

  if [ $# -eq 1 ]; then
    shellspec_output SYNTAX_ERROR_EVALUATION "Missing evaluation type"
    shellspec_on FAILED
    return 0
  fi

  shellspec_statement_evaluation "$@"
  shellspec_output EVALUATION
}

shellspec_the() {
  SHELLSPEC_EXPECTATION="The ${*:-}"
  shellspec_off NOT_IMPLEMENTED
  shellspec_on EXPECTATION

  if [ $# -eq 0 ]; then
    shellspec_output SYNTAX_ERROR_EXPECTATION "Missing expectation"
    shellspec_on FAILED
    return 0
  fi

  shellspec_statement_preposition "$@"
}

shellspec_before() { eval shellspec_before_hook ${1+'"$@"'}; }
shellspec_after()  { eval shellspec_after_hook ${1+'"$@"'}; }

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
    SHELLSPEC_SKIP_REASON="$2"
    SHELLSPEC_CONDITIONAL_SKIP=1
    shift 2
    ( "$@" ) || return 0
  else
    SHELLSPEC_SKIP_REASON="${1:-}"
    SHELLSPEC_CONDITIONAL_SKIP=
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

shellspec_include() {
  eval . ${1+'"$@"'};
}

shellspec_logger() {
  shellspec_output LOG "${*:-}"
}

shellspec_marker() {
  shellspec_putsn "${SHELLSPEC_SYN}shellspec_marker:${*:-}" >&2
}

shellspec_abort() {
  shellspec_putsn "${2:-}" >&2
  [ "${3:-}" ] && shellspec_putsn "${3:-}" >&2
  exit "${1:-1}"
}
