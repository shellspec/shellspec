#shellcheck shell=sh

error() {
  [ $# -gt 0 ] || return 0
  IFS=" $IFS"; "$SHELLSPEC_PRINTF" '%s\n' "$*" >&2; IFS=" ${IFS#?}"
}

warn() {
  [ $# -gt 0 ] || return 0
  IFS=" $IFS"; "$SHELLSPEC_PRINTF" '%s\n' "$*" >&3; IFS=" ${IFS#?}"
}

info() {
  [ $# -gt 0 ] || return 0
  IFS=" $IFS"; "$SHELLSPEC_PRINTF" '%s\n' "$*" >&4; IFS=" ${IFS#?}"
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
    echo "minimum_version: The minimum version is not specified" >&2
    return 1
  fi
  case ${1%%[+-]*} in
    *.*.*.*) set -- "x$1" ;;
    ?*.?*.?*) case ${1%%[+-]*} in (*[!0-9.]*) set -- "x$1"; esac ;;
    *) set -- "x$1" ;;
  esac
  if [ ! "${1#x}" = "$1" ]; then
    echo "minimum_version:" \
      "Invalid version format (major.minor.patch[-pre][+build]): ${1#x}" >&2
    return 1
  fi

  set -- "$1" "$VERSION"
  set -- "$1" "${1%%-*}" "${1%%+*}" "$2" "${2%%-*}" "${2%%+*}"
  case $((${#2} - ${#3})) in
    0 ) set -- "$@" "${1%%-*}.0" ;;
    -*) set -- "$@" "${1%%-*}.-1" ;;
    * ) set -- "$@" "${1%%+*}.+1" ;;
  esac
  case $((${#5} - ${#6})) in
    0 ) set -- "$@" "${4%%-*}.0" ;;
    -*) set -- "$@" "${4%%-*}.-1" ;;
    * ) set -- "$@" "${4%%+*}.+1" ;;
  esac

  set -- "$@" "$1"
  shift 6
  IFS=".$IFS"
  eval "set -- \$${ZSH_VERSION:+=}1 \$${ZSH_VERSION:+=}2 \"\$3\""
  IFS="${IFS#?}"

  while [ $# -gt 5 ]; do
    [ "$1" -lt "$5" ] && return 0
    if [ "$1" -gt "$5" ]; then
      [ $# -gt 0 ] && shift $(($# - 1))
      echo "ShellSpec version $1 or higher is required">&2
      return 1
    fi
    shift
  done
  return 0
}
