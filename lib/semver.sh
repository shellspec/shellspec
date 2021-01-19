#shellcheck shell=sh

check_semver() {
  case $1 in (*[!0-9a-zA-Z.+-]*)
    return 1
  esac
  case ${1%%[+-]*} in
    *.*.*.*) return 1 ;;
    ?*.?*.?*) case ${1%%[+-]*} in (*[!0-9.]*) return 1; esac ;;
    *) return 1 ;;
  esac
  return 0
}

semver() {
  case $2 in
    -lt) set -- "$1" "$2" "$3" -eq 1 ;;
    -le) set -- "$1" "$2" "$3" -ne 2 ;;
    -eq) set -- "$1" "$2" "$3" -eq 0 ;;
    -ne) set -- "$1" "$2" "$3" -ne 0 ;;
    -gt) set -- "$1" "$2" "$3" -eq 2 ;;
    -ge) set -- "$1" "$2" "$3" -ne 1 ;;
    *) echo "Unexpected operator: $2" >&2; exit 1 ;;
  esac
  cmp_semver "$1" "$3" &&:
  test $? "$4" "$5"
}

cmp_semver() {
  set -- "$1" "${1%%[+-]*}" "${1%%+*}" "$2" "${2%%[+-]*}" "${2%%+*}"
  case $3 in
    *-*) set -- "$@" "$2.-1" ;;
    *  ) set -- "$@" "$2.0" ;;
  esac
  case $6 in
    *-*) set -- "$@" "$5.-1" ;;
    *  ) set -- "$@" "$5.0" ;;
  esac

  set -- "$@"
  shift 6
  IFS=".$IFS"
  eval "set -- \$${ZSH_VERSION:+=}1 \$${ZSH_VERSION:+=}2"
  IFS="${IFS#?}"

  while [ $# -gt 4 ]; do
    [ "$1" -lt "$5" ] && return 1
    [ "$1" -gt "$5" ] && return 2
    shift
  done
  return 0
}
