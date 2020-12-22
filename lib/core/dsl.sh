#shellcheck shell=sh disable=SC2004

# shellcheck disable=SC2034
SHELLSPEC_PATH_ALIAS='|'
SHELLSPEC_INTERCEPTOR='|'
SHELLSPEC_STDIN_FILE=''
SHELLSPEC_STDOUT_FILE=''
SHELLSPEC_STDERR_FILE=''
SHELLSPEC_LINENO=''
SHELLSPEC_LINENO_BEGIN=''
SHELLSPEC_LINENO_END=''
SHELLSPEC_AUX_LINENO=''
SHELLSPEC_ENABLED=''
SHELLSPEC_FOCUSED=''
SHELLSPEC_SPEC_NO=''
SHELLSPEC_GROUP_ID=''
SHELLSPEC_BLOCK_NO=''
SHELLSPEC_EXAMPLE_ID=''
SHELLSPEC_EXAMPLE_NO=''
SHELLSPEC_EXAMPLE_COUNT=''
SHELLSPEC_DESCRIPTION=''
SHELLSPEC_EXPECTATION=''
SHELLSPEC_EVALUATION=''
SHELLSPEC_HOOK=''
SHELLSPEC_SKIP_ID=''
SHELLSPEC_SKIP_REASON=''
SHELLSPEC_PENDING_REASON=''
SHELLSPEC_SHELL_OPTIONS=''
SHELLSPEC_HOOK_ERROR=''

shellspec_group_id() {
  # shellcheck disable=SC2034
  SHELLSPEC_GROUP_ID=$1 SHELLSPEC_BLOCK_NO=$2
}

shellspec_example_id() {
  # shellcheck disable=SC2034
  SHELLSPEC_EXAMPLE_ID=$1 SHELLSPEC_EXAMPLE_NO=$2 SHELLSPEC_BLOCK_NO=$3
}

shellspec_metadata() {
  if [ "${1:-}" ]; then
    shellspec_output METADATA
  fi
}

shellspec_finished() {
  if [ "${1:-}" ]; then
    shellspec_output FINISHED
  else
    shellspec_output_to_fd shellspec_putsn
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
  # shellcheck disable=SC2034
  SHELLSPEC_SPECFILE=$1 SHELLSPEC_SPEC_NO=$2 SHELLSPEC_GROUP_ID=''
  SHELLSPEC_WORKDIR="$SHELLSPEC_TMPBASE/$SHELLSPEC_SPEC_NO"
  SHELLSPEC_ERROR_FILE="$SHELLSPEC_WORKDIR/error"
  shellspec_output BEGIN
}

shellspec_execdir() {
  case $1 in
    @project | @project/*) set -- "${1#@project}" ;;
    @basedir | @basedir/*)
      set -- "$1" "/${SHELLSPEC_SPECFILE%/*}"
      while [ "$2" ]; do
        [ -e "${SHELLSPEC_PROJECT_ROOT%/}/$2/.shellspec" ] && break
        [ -e "${SHELLSPEC_PROJECT_ROOT%/}/$2/.shellspec-basedir" ] && break
        set -- "$1" "${2%/*}"
      done
      set -- "${2#/}${1#@basedir}"
      ;;
    @specfile | @specfile/*) set -- "${SHELLSPEC_SPECFILE%/*}${1#@specfile}" ;;
    *) set -- ""
  esac
  case $1 in
    /*) set -- "$1" ;;
    ?*) set -- "/$1" ;;
  esac
  cd "${SHELLSPEC_PROJECT_ROOT%/}$1"
}

shellspec_perform() {
  SHELLSPEC_ENABLED=$1 SHELLSPEC_FILTER=$2
}

shellspec_end() {
  # shellcheck disable=SC2034
  SHELLSPEC_EXAMPLE_COUNT=${1:-}
  shellspec_output END
}

shellspec_include_pack() {
  eval "$1=\$3; shift 3; eval shellspec_pack $2 \${1+'\"\$@\"'}"
}

shellspec_before_first_block() {
  shellspec_mark_group "$SHELLSPEC_BLOCK_NO" ""
  [ "$SHELLSPEC_DRYRUN" ] && return 0
  shellspec_if SKIP && return 0
  if ! shellspec_call_before_hooks ALL; then
    shellspec_output BEFORE_ALL_ERROR
    SHELLSPEC_HOOK_ERROR=1
  fi
  shellspec_mark_group "$SHELLSPEC_BLOCK_NO" 1
}

shellspec_after_last_block() {
  if ! shellspec_call_after_hooks ALL; then
    shellspec_output AFTER_ALL_ERROR
  fi
}

shellspec_after_block() {
  shellspec_call_after_hooks MOCK
}

shellspec_description() {
  if [ "${2:-}" = "@" ]; then
    set -- "$1" "<$1:$SHELLSPEC_LINENO_BEGIN-$SHELLSPEC_LINENO_END>"
  fi
  [ "$1" = "example_group" ] && set -- "$1" "${2:-}${2:+$SHELLSPEC_VT}"
  SHELLSPEC_DESCRIPTION="${SHELLSPEC_DESCRIPTION}$2"
}

shellspec_example_group() {
  shellspec_description "example_group" "${1:-}"
  shellspec_yield
}

shellspec_example_block() {
  SHELLSPEC_STDIO_FILE_BASE="$SHELLSPEC_WORKDIR/$SHELLSPEC_EXAMPLE_ID"
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
  case $SHELLSPEC_STDIO_FILE_BASE in
    *\#*) eval "set -- ${SHELLSPEC_STDIO_FILE_BASE##*\#} ${1+\"\$@\"}" ;;
    *) eval "set -- 0 ${1+\"\$@\"}" ;;
  esac
  SHELLSPEC_STDIO_FILE_BASE="${SHELLSPEC_STDIO_FILE_BASE%\#*}#$(($1 + 1))"
  shift

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

  # shellcheck disable=SC2034
  SHELLSPEC_STDIN_FILE="$SHELLSPEC_STDIO_FILE_BASE.stdin"
  SHELLSPEC_STDOUT_FILE="$SHELLSPEC_STDIO_FILE_BASE.stdout"
  SHELLSPEC_STDERR_FILE="$SHELLSPEC_STDIO_FILE_BASE.stderr"
  SHELLSPEC_LEAK_FILE="$SHELLSPEC_STDIO_FILE_BASE.leak"
  SHELLSPEC_XTRACE_FILE="$SHELLSPEC_STDIO_FILE_BASE.trace"
  export SHELLSPEC_VARS_FILE="$SHELLSPEC_STDIO_FILE_BASE.vars"

  [ "$SHELLSPEC_ENABLED" ] || return 0
  [ "$SHELLSPEC_FILTER" ] || return 0

  if [ "$SHELLSPEC_DRYRUN" ]; then
    shellspec_output EXAMPLE
    shellspec_output SUCCEEDED
    return 0
  fi

  shellspec_profile_start
  case $- in
    *e*) eval "set -- -e ${1+\"\$@\"}" ;;
    *) eval "set -- +e ${1+\"\$@\"}" ;;
  esac
  set +e
  ( set -e
    shift
    case $# in
      0) shellspec_invoke_example 3>&2 ;;
      *) shellspec_invoke_example "$@" 3>&2 ;;
    esac
  )
  set "$1" -- $? "$SHELLSPEC_LEAK_FILE"
  if [ "$1" -ne 0 ]; then
    [ -s "$2" ] || set -- "$1" "$SHELLSPEC_STDERR_FILE"
    shellspec_output ABORTED "$@"
    shellspec_output FAILED
  fi
  shellspec_profile_end
}

shellspec_invoke_example() {
  shellspec_output EXAMPLE

  shellspec_on NOT_IMPLEMENTED
  shellspec_off FAILED WARNED EXPECTATION LEAK
  shellspec_off UNHANDLED_STATUS UNHANDLED_STDOUT UNHANDLED_STDERR

  # Output SKIP message if skipped in outer group.
  if ! shellspec_output_if SKIP; then
    if [ "$SHELLSPEC_HOOK_ERROR" ]; then
      shellspec_output HOOK_ERROR "$SHELLSPEC_HOOK_ERROR"
      shellspec_output FAILED
      return 0
    fi
    if ! shellspec_call_before_hooks EACH; then
      shellspec_output BEFORE_EACH_ERROR
      shellspec_output FAILED
      return 0
    fi
    shellspec_output_if PENDING ||:
    case $# in
      0) shellspec_yield 2>"$SHELLSPEC_LEAK_FILE" ;;
      *) shellspec_yield "$@" 2>"$SHELLSPEC_LEAK_FILE" ;;
    esac
    if ! shellspec_call_after_hooks EACH; then
      shellspec_output AFTER_EACH_ERROR
      shellspec_output FAILED
      return 0
    fi
  fi

  shellspec_if SKIP && shellspec_unless FAILED && {
    shellspec_output SKIPPED && return 0
  }

  shellspec_if NOT_IMPLEMENTED && {
    SHELLSPEC_PENDING_REASON="Not yet implemented"
    shellspec_output NOT_IMPLEMENTED
    shellspec_output TODO
    return 0
  }

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

  [ -s "$SHELLSPEC_LEAK_FILE" ] && shellspec_on LEAK
  shellspec_output_if LEAK "$SHELLSPEC_LEAK_FILE" && shellspec_on FAILED
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
  eval shellspec_join SHELLSPEC_EVALUATION '" "' When ${1+'"$@"'}
  shellspec_off NOT_IMPLEMENTED

  shellspec_if EVALUATION && {
    set -- "Evaluation has already been executed." \
      "Only one Evaluation allow per Example." \
      "(Use 'parameterized example' if you want a loop)"
    shellspec_output SYNTAX_ERROR_EVALUATION "$1 $2${SHELLSPEC_LF}$3"
    shellspec_on FAILED
    return 0
  }
  shellspec_on EVALUATION

  shellspec_if EXPECTATION && {
    set -- "Expectation has already been executed."
    shellspec_output SYNTAX_ERROR_EVALUATION "$1"
    shellspec_on FAILED
    return 0
  }

  if [ $# -eq 0 ]; then
    shellspec_output SYNTAX_ERROR_EVALUATION "Missing evaluation type."
    shellspec_on FAILED
    return 0
  fi

  if [ $# -eq 1 ]; then
    shellspec_output SYNTAX_ERROR_EVALUATION "Missing evaluation."
    shellspec_on FAILED
    return 0
  fi

  shellspec_output EVALUATION
  shellspec_statement_evaluation "$@"
}

shellspec_around_call() {
  shellspec_call_before_evaluation_hooks CALL || return "$?"
  "$@"
  set -- $?
  [ "$1" -ne 0 ] && return "$1"
  shellspec_call_after_evaluation_hooks CALL || return "$?"
}

shellspec_around_run() {
  shellspec_call_before_evaluation_hooks RUN || return "$?"
  "$@"
  set -- $?
  [ "$1" -ne 0 ] && return "$1"
  shellspec_call_after_evaluation_hooks RUN || return "$?"
}

shellspec_the() {
  eval shellspec_join SHELLSPEC_EXPECTATION '" "' The ${1+'"$@"'}
  shellspec_off NOT_IMPLEMENTED
  shellspec_on EXPECTATION
  [ "$SHELLSPEC_XTRACE_ONLY" ] && return 0

  if [ $# -eq 0 ]; then
    shellspec_output SYNTAX_ERROR_EXPECTATION "Missing expectation"
    shellspec_on FAILED
    return 0
  fi

  shellspec_statement_preposition "$@"
}

shellspec_assert() {
  eval shellspec_join SHELLSPEC_EXPECTATION '" "' Assert ${1+'"$@"'}
  shellspec_off NOT_IMPLEMENTED
  shellspec_on EXPECTATION
  [ "$SHELLSPEC_XTRACE_ONLY" ] && return 0

  if [ $# -eq 0 ]; then
    shellspec_output SYNTAX_ERROR_EXPECTATION "Missing assertion"
    shellspec_on FAILED
    return 0
  fi

  SHELLSPEC_ASSERT_STDERR_FILE="$SHELLSPEC_WORKDIR/assert.stderr"

  case $- in
    *e*) eval "set -- -e ${1+\"\$@\"}" ;;
    *) eval "set -- +e ${1+\"\$@\"}" ;;
  esac
  set +e
  ( set -e; shift; "$@" </dev/null 2>"$SHELLSPEC_ASSERT_STDERR_FILE" )
  set "$1" -- $?

  shellspec_readfile SHELLSPEC_ASSERT_STDERR "$SHELLSPEC_ASSERT_STDERR_FILE"

  if [ "$1" -eq 0 ]; then
    if [ "$SHELLSPEC_ASSERT_STDERR" ]; then
      shellspec_output ASSERT_WARN "$1"
      shellspec_output_assert_message "$SHELLSPEC_ASSERT_STDERR"
      shellspec_on WARNED
      return 0
    fi
    shellspec_output MATCHED
    return 0
  fi

  shellspec_output ASSERT_ERROR "$1"
  shellspec_output_assert_message "$SHELLSPEC_ASSERT_STDERR"
  shellspec_on FAILED
}

shellspec_proxy shellspec_before_all "shellspec_register_before_hook ALL"
shellspec_proxy shellspec_after_all "shellspec_register_after_hook ALL"

shellspec_proxy shellspec_before "shellspec_register_before_hook EACH"
shellspec_proxy shellspec_after "shellspec_register_after_hook EACH"

shellspec_proxy shellspec_before_each "shellspec_register_before_hook EACH"
shellspec_proxy shellspec_after_each "shellspec_register_after_hook EACH"

shellspec_proxy shellspec_before_call "shellspec_register_before_hook CALL"
shellspec_proxy shellspec_after_call "shellspec_register_after_hook CALL"

shellspec_proxy shellspec_before_run "shellspec_register_before_hook RUN"
shellspec_proxy shellspec_after_run "shellspec_register_after_hook RUN"

shellspec_proxy shellspec_after_mock "shellspec_register_after_hook MOCK"

shellspec_path() {
  while [ $# -gt 0 ]; do
    SHELLSPEC_PATH_ALIAS="${SHELLSPEC_PATH_ALIAS}$1|"
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
  SHELLSPEC_PENDING_REASON="${1:-}"
  shellspec_off NOT_IMPLEMENTED
  # Output PENDING message if within the example group
  [ "${SHELLSPEC_EXAMPLE_NO:-}" ] && shellspec_output PENDING
  # if already failed, can not pending
  shellspec_if FAILED || shellspec_on PENDING
}

shellspec_logger() {
  shellspec_sleep 0
  if [ "$SHELLSPEC_LOGFILE" ]; then
    shellspec_putsn "$@" >>"$SHELLSPEC_LOGFILE"
  else
    shellspec_putsn "$@"
  fi
}

shellspec_deprecated() {
  set -- "${SHELLSPEC_SPECFILE:-}:${SHELLSPEC_LINENO:-$SHELLSPEC_LINENO_BEGIN}" "$@"
  shellspec_putsn "$@" >>"$SHELLSPEC_DEPRECATION_LOGFILE"
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

shellspec_is_temporary_skip() {
  case ${SHELLSPEC_SKIP_REASON:-} in ("" | \# | \#\ *) ;; (*) false; esac
}

shellspec_is_temporary_pending() {
  case ${SHELLSPEC_PENDING_REASON:-} in ("" | \# | \#\ *) ;; (*) false; esac
}

shellspec_cat() {
  # shellcheck disable=SC2154
  ( while IFS= read -r shellspec_cat || [ "$shellspec_cat" ]; do
      shellspec_putsn "$shellspec_cat"
    done
  )
}

# shellcheck disable=SC2034
shellspec_filter() {
  if [ "${1:-}" ]; then SHELLSPEC_ENABLED=$1; fi
  if [ "${2:-}" ]; then SHELLSPEC_FOCUSED=$2; fi
  if [ "${3:-}" ]; then SHELLSPEC_FILTER=$3; fi
}

shellspec_dump() {
  set -- ""
  if [ "${SHELLSPEC_STDOUT+x}" ]; then
    set -- "$@" "[stdout]${SHELLSPEC_LF}${SHELLSPEC_STDOUT}"
  else
    set -- "$@" "[stdout] <unset>"
  fi
  if [ "${SHELLSPEC_STDERR+x}" ]; then
    set -- "$@" "[stderr]${SHELLSPEC_LF}${SHELLSPEC_STDERR}"
  else
    set -- "$@" "[stderr] <unset>"
  fi
  set -- "$@" "[status] ${SHELLSPEC_STATUS-<unset>}" ""
  IFS="${SHELLSPEC_LF}${IFS}"
  shellspec_putsn "$*"
  IFS=${IFS#?}
}

shellspec_preserve() {
  [ $# -eq 0 ] && return 0
  shellspec_clone "$@" >> "$SHELLSPEC_VARS_FILE"
}

shellspec_mock() {
  set -- "$SHELLSPEC_MOCK_BINDIR/$1" 1
  if [ -e "$1" ]; then
    while [ -e "$1#$2" ]; do
      set -- "$1" $(($2 + 1))
    done
    shellspec_mv "$1" "$1#$2"
  fi
  shellspec_create_mock_file "$1"
  shellspec_chmod +x "$1"
}

shellspec_create_mock_file() {
  shellspec_gen_mock_code "$SHELLSPEC_SHELL" > "$1"
}

shellspec_gen_mock_code() {
  shellspec_putsn "#!$1"
  shellspec_putsn ". \"\$SHELLSPEC_LIB/general.sh\""
  shellspec_putsn ". \"\$SHELLSPEC_LIB/core/clone.sh\""
  shellspec_putsn "if [ -e \"\$SHELLSPEC_VARS_FILE\" ]; then"
  shellspec_putsn "  . \"\$SHELLSPEC_VARS_FILE\""
  shellspec_putsn "fi"
  shellspec_putsn "shellspec_preserve() {"
  shellspec_putsn "  [ \$# -eq 0 ] && return 0"
  shellspec_putsn "  shellspec_clone \"\$@\" >> \"\$SHELLSPEC_VARS_FILE\""
  shellspec_putsn "}"
  shellspec_cat
}

shellspec_unmock() {
  set -- "$SHELLSPEC_MOCK_BINDIR/$1" 0
  [ -e "$1" ] && shellspec_rm "$1"
  while [ -e "$1#$(($2 + 1))" ]; do
    set -- "$1" $(($2 + 1))
  done
  if [ "$2" -gt 0 ]; then
    shellspec_mv "$1#$2" "$1"
  fi
}
