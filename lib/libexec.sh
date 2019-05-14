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

merge_specfiles() {
  case $1 in (*:*) set -- "${1%%:*}" ":${1#*:}"; esac
  if ! is_specfile "$1"; then return 0; fi
  found_specfiles="${SHELLSPEC_LF}${found_specfiles}"
  found_specfiles_=${found_specfiles%%"${SHELLSPEC_LF}$1"[$SHELLSPEC_LF:]*}
  if [ "$found_specfiles" = "$found_specfiles_" ]; then
    found_specfiles=${found_specfiles}${1}${2:-}${SHELLSPEC_LF}
  else
    found_specfiles=${found_specfiles#"${found_specfiles_}${SHELLSPEC_LF}"}
    found_specfiles_=${found_specfiles_}${SHELLSPEC_LF}
    found_specfiles_=${found_specfiles_}${found_specfiles%%"$SHELLSPEC_LF"*}
    found_specfiles_=${found_specfiles_}${2:-}${SHELLSPEC_LF}
    found_specfiles=${found_specfiles_}${found_specfiles#*"$SHELLSPEC_LF"}
  fi
  found_specfiles=${found_specfiles#?}
}

invoke_specfile() {
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
  callback=$1 found_specfiles=""
  shift
  eval shellspec_find_files merge_specfiles ${1+'"$@"'}
  while [ "$found_specfiles" ]; do
    found_specfile=${found_specfiles%%"$SHELLSPEC_LF"*}
    found_specfiles=${found_specfiles#*"$SHELLSPEC_LF"}
    invoke_specfile "$callback" "$found_specfile"
  done
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
