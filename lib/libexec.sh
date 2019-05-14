#shellcheck shell=sh

[ "${ZSH_VERSION:-}" ] && setopt shwordsplit

# shellcheck source=lib/general.sh
. "${SHELLSPEC_LIB:-./lib}/general.sh"

use() {
  while [ $# -gt 0 ]; do
    case $1 in
      constants) shellspec_constants ;;
      reset_params)
        reset_params() {
          shellspec_reset_params "$@"
          eval 'RESET_PARAMS=$SHELLSPEC_RESET_PARAMS'
        }
        ;;
      *) shellspec_proxy "$1" "shellspec_$1" ;;
    esac
    shift
  done
}

load() {
  while [ "$#" -gt 0 ]; do
    # shellcheck disable=SC1090
    . "${SHELLSPEC_LIB:-./lib}/libexec/$1.sh"
    shift
  done
}

is_specfile() {
  # This &&: workaround for #21 in contrib/bugs.sh
  eval "case \${1%%:*} in ($SHELLSPEC_PATTERN) true ;; (*) false ; esac &&:"
}

found_specfile() {
  set -- "$@" "${2%%:*}"
  case $2 in (*:*)
    set -- "$@" "${2#*:}"
    until case $4 in (*:*) false; esac; do
      set -- "$1" "$2" "$3" "${4%%:*} ${4#*:}"
    done
  esac
  "$@"
}

find_specfiles() {
  eval "found_() { ! is_specfile \"\$1\" || found_specfile \"$1\" \"\$1\"; }"
  shift
  if [ "${1:-}" = "-" ]; then
    [ -e "$SHELLSPEC_INFILE" ] || return 0
    while IFS= read -r line || [ "$line" ]; do
      [ "$line" ] || continue
      eval shellspec_find_files found_ "$line"
    done < "$SHELLSPEC_INFILE"
  else
    eval shellspec_find_files found_ ${1+'"$@"'}
  fi
}

display() {
  (
    while IFS= read -r line || [ "$line" ]; do
      putsn "$line"
    done < "$1"
  )
}

warn() {
  if [ "$SHELLSPEC_COLOR" ]; then
    printf '\033[33m%s\033[0m\n' "${*:-}" >&2
  else
    printf '%s\n' "${*:-}" >&2
  fi
}

info() {
  if [ "$SHELLSPEC_COLOR" ]; then
    printf '\033[33m%s\033[0m\n' "$*"
  else
    printf '%s\n' "$*"
  fi
}

error() {
  if [ "$SHELLSPEC_COLOR" ]; then
    printf '\33[2;31m%s\33[0m\n' "${*:-}" >&2
  else
    printf '%s\n' "${*:-}" >&2
  fi
}

abort() {
  error "$@"
  exit 1
}

use puts putsn
