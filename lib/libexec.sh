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
  eval "case \$1 in ($SHELLSPEC_PATTERN) true ;; (*) false ; esac &&:"
}

find_specfiles_() {
  if ! is_specfile "${1%%:*}"; then return 0; fi
  case $1 in
    *:*)
      set -- "${1%%:*}" "${1#*:}"
      while :; do
        case $2 in (*:*) set -- "$1" "${2%%:*} ${2#*:}" ;; (*) break ;; esac
      done
      found_specfile_ "$1" "$2"
      ;;
    *) found_specfile_ "$1" ;;
  esac
}

find_specfiles() {
  eval "found_specfile_() { \"$1\" \"\$@\"; }"
  shift
  eval shellspec_find_files find_specfiles_ ${1+'"$@"'}
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
