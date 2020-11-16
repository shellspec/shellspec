# shellcheck shell=sh

optparser() {
  # shellcheck source=lib/getoptions.sh
  . "$SHELLSPEC_LIB/getoptions.sh"
  # shellcheck source=lib/getoptions_help.sh
  . "$SHELLSPEC_LIB/getoptions_help.sh"
  # shellcheck source=lib/getoptions_abbr.sh
  . "$SHELLSPEC_LIB/getoptions_abbr.sh"
  # shellcheck source=lib/libexec/parser_definition.sh
  . "$SHELLSPEC_LIB/libexec/parser_definition.sh"

  eval "$(getoptions parser_definition "$@")"
}

multiple() {
  eval "export $1=\"\${$1}\${$1:+$2}\$OPTARG\""
}

boost() {
  case $OPTARG in
    1) export "$1_PROFILER=1" "$1_PROFILER_LIMIT=0" ;;
    *) export "$1_PROFILER=" "$1_PROFILER_LIMIT=10" ;;
  esac
}

check_env_name() {
  case ${OPTARG%%\=*} in ([!a-zA-Z_]*) return 1; esac
  case ${OPTARG%%\=*} in (*[!a-zA-Z0-9_]*) return 1; esac
  return 0
}

set_path() {
  export "$1=$OPTARG"
}

set_env() {
  case $OPTARG in
    *=*) set -- "${OPTARG%%\=*}" "${OPTARG#*\=}" ;;
    *)
      eval "[ \${$OPTARG+x} ] &&:" || return 0
      eval "set -- \"\$OPTARG\" \"\${$OPTARG}\""
  esac
  export "$1=$2"
}

check_env_file() {
  case $OPTARG in
    /* | ./* | ../*) : ;;
    *) OPTARG="./$OPTARG" ;;
  esac
  [ -f "$OPTARG" ]
}

only_failures() {
  export "$1_QUICK=1" "$1_REPAIR=1"
}

next_failure() {
  export "$1_QUICK=1" "$1_REPAIR=1" "$1_FAIL_FAST_COUNT=1" "$1_RANDOM="
}

check_random() {
  case $OPTARG in
    none | none:*) return 0 ;;
    specfiles | specfiles:*) return 0 ;;
    examples | examples:*) return 0 ;;
  esac
  return 1
}

random() {
  case $OPTARG in (none | none:*)
    OPTARG=''
  esac
  case $OPTARG in
    *:*) export "$1_RANDOM=${OPTARG%%:*}" "$1_SEED=${OPTARG#*:}" ;;
    *) export "$1_RANDOM=$OPTARG" "$1_SEED=" ;;
  esac
}

xtrace() {
  case $OPTARG in
    0) export "$1_XTRACE=" "$1_XTRACE_ONLY=" ;;
    1) export "$1_XTRACE=1" "$1_XTRACE_ONLY" ;;
    2) export "$1_XTRACE=1" "$1_XTRACE_ONLY=1" ;;
  esac
}

is_terminal() { [ -t 1 ]; }
detect_color_mode() {
  export "$1_COLOR="
  [ "${NO_COLOR:-}" ] && return 0
  if is_terminal || [ "${FORCE_COLOR:-}" ]; then
    export "$1_COLOR=1"
  fi
}

quiet() {
  export "$1_SKIP_MESSAGE=quiet" "$1_PENDING_MESSAGE=quiet"
}

mode() {
  case $OPTARG in
    specfiles | examples | examples:id | examples:lineno | debug)
      export "$1_MODE=list" "$1_LIST=$OPTARG" ;;
    count) export "$1_MODE=list" "$1_LIST=" ;;
    *) export "$1_MODE=$OPTARG" "$1_LIST=" ;;
  esac
}

check_number() {
  case $OPTARG in (*[!0-9]*) return 1; esac
  return 0
}

check_formatter() {
  case $OPTARG in (*[!a-z0-9_]*) return 1; esac
  set -- progress documentation tap junit failures
  while [ $# -gt 0 ]; do
    case $1 in ($OPTARG*) OPTARG=$1; esac
    shift
  done
  return 0
}

help() {
  usage | while IFS= read -r line; do
    if [ "$1" = "--help" ]; then
      echo "${line%\ \|\ *}"
    else
      spaces=${line%%[! ]*}
      [ ${#spaces} -ge 10 ] || echo "$line"
    fi
  done
}

error_handler() {
  # $1: echo or output function
  # $2: Default error message
  # $3: Error name
  # $4: Option
  # $5-: Validator name and arguments
  case $3 in
    check_number:*) set -- "$1" "Not a number: $4" ;;
    check_formatter:*) set -- "$1" "Invalid formatter name: $4" ;;
    check_env_name:*) set -- "$1" "Invalid environment name: $4" ;;
    check_env_file:*) set -- "$1" "Not found env file: $4" ;;
    check_random:*)
      set -- "$1" "Specify in one of the following formats" "$4"
      set -- "$1" "$2 (none[:SEED], specfiles[:SEED], examples[:SEED]): $3"
  esac
  "$1" "$2"
  return 1
}

deprecated() {
  case $1 in
    --keep-tempdir)
      warn "--keep-tempdir is deprecated. replace with --keep-tmpdir."
  esac
}
