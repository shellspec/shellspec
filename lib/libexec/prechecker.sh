#shellcheck shell=sh

# shellcheck source=lib/semver.sh
. "${SHELLSPEC_LIB:-./lib}/semver.sh"

error() {
  [ $# -gt 0 ] || return 0
  IFS=" $IFS"; "$SHELLSPEC_PRINTF" '[error] %s\n' "$*" >&2; IFS=" ${IFS#?}"
}

warn() {
  [ $# -gt 0 ] || return 0
  IFS=" $IFS"; "$SHELLSPEC_PRINTF" '[warn] %s\n' "$*" >&3; IFS=" ${IFS#?}"
}

info() {
  [ $# -gt 0 ] || return 0
  IFS=" $IFS"; "$SHELLSPEC_PRINTF" '[info] %s\n' "$*" >&4; IFS=" ${IFS#?}"
}

abort() {
  [ $# -gt 0 ] || return 0
  case $1 in
    *[!0-9]*) error "$@"; exit 1 ;;
    *) xs=$1; shift ;;
  esac
  [ $# -eq 0 ] && set -- "Aborted (exit status: $xs)"
  error "$@"
  exit "$xs"
}

minimum_version() {
  if [ $# -eq 0 ]; then
    abort "minimum_version: The minimum version is not specified"
  fi

  if ! check_semver "$1"; then
    abort "minimum_version: Invalid version format (major.minor.patch[-pre][+build]): $1"
  fi

  if ! semver "$1" -le "$VERSION"; then
    abort "ShellSpec version $1 or higher is required"
  fi
}

setenv() {
  while [ $# -gt 0 ]; do
    if ! ( export "${1%%\=*}=" ) 2>/dev/null; then
      abort "setenv: Invalid environment variable name: ${1%%\=*}"
    fi
    case $1 in
      *=*) setenv_ "${1%%\=*}" "${1#*\=}" ;;
      *) abort "setenv: No value for environment variable: $1"
    esac
    shift
  done
}

setenv_() {
  set -- "$1" "$2'" ""
  while [ "$2" ]; do
    set -- "$1" "${2#*\'}" "$3${2%%\'*}'\''"
  done
  set -- "$1" "${3%????}"
  echo "export $1='$2'" >&9
}

unsetenv() {
  while [ $# -gt 0 ]; do
    if ! ( export "$1=" ) 2>/dev/null; then
      abort "unsetenv: Invalid environment variable name: $1"
    fi
    echo "unset $1 ||:" >&9
    shift
  done
}
