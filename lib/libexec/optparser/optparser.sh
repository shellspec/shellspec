# shellcheck shell=sh

# shellcheck source=lib/getoptions.sh
# . "$SHELLSPEC_LIB/getoptions.sh"
# shellcheck source=lib/getoptions_help.sh
# . "$SHELLSPEC_LIB/getoptions_help.sh"
# shellcheck source=lib/getoptions_abbr.sh
# . "$SHELLSPEC_LIB/getoptions_abbr.sh"

optparser() {
  eval "$1() { if [ \$# -gt 0 ]; then optparser_parse \"\$@\"; fi; }"
  eval "optparser_error() { $2 \"\$@\"; }"

  # . "$SHELLSPEC_LIB/libexec/optparser/parser_definition.sh"
  # set -- "optparser_parse" "SHELLSPEC" "optparser_error"
  # eval "$(getoptions parser_definition "$@")"

  # shellcheck source=lib/libexec/optparser/parser_definition_generated.sh
  . "$SHELLSPEC_LIB/libexec/optparser/parser_definition_generated.sh"
}

multiple() {
  eval "export $1=\"\${$1}\${$1:+$2}\$OPTARG\""
}

array() {
  set -- "$1" "$OPTARG'" ""
  while [ "$2" ]; do
    set -- "$1" "${2#*\'}" "$3${2%%\'*}'\''"
  done
  OPTARG=${3%????}
  eval "export $1=\"\${$1}\${$1:+ }'\$OPTARG'\""
}

boost() {
  case $OPTARG in
    1) export "$1_PROFILER=1" "$1_PROFILER_LIMIT=0" ;;
    *) export "$1_PROFILER=" "$1_PROFILER_LIMIT=10" ;;
  esac
}

check_module_name() {
  case $OPTARG in ([!a-zA-Z_]*) return 1; esac
  case $OPTARG in (*[!a-zA-Z0-9_]*) return 1; esac
  return 0
}

check_env_name() {
  case ${OPTARG%%\=*} in ([!a-zA-Z_]*) return 1; esac
  case ${OPTARG%%\=*} in (*[!a-zA-Z0-9_]*) return 1; esac
  return 0
}

directory_not_available() { false; }

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

check_execdir() {
  case $OPTARG in
    */.. | */../* ) return 1
  esac
  return 0
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
    directory_not_available:*)
      set -- "$1" "The $4 option must be specified before other options and cannot be specified in an options file" ;;
    check_number:*) set -- "$1" "Not a number: $4" ;;
    check_module_name:*) set -- "$1" "Invalid module name: $4" ;;
    check_formatter:*) set -- "$1" "Invalid formatter name: $4" ;;
    check_env_name:*) set -- "$1" "Invalid environment name: $4" ;;
    check_env_file:*) set -- "$1" "Not found env file: $4" ;;
    check_execdir:*) set -- "$1" "Cannot include '..' in the execution directory: $4" ;;
    check_random:*)
      set -- "$1" "Specify in one of the following formats" "$4"
      set -- "$1" "$2 (none[:SEED], specfiles[:SEED], examples[:SEED]): $3"
  esac
  "$1" "$2"
  return 1
}

deprecated() {
  warn "$1 is deprecated.${2:+ }${2:-}"
}
