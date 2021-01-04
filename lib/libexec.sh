#shellcheck shell=sh disable=SC2004

[ "${ZSH_VERSION:-}" ] && setopt shwordsplit

# shellcheck source=lib/general.sh
. "${SHELLSPEC_LIB:-./lib}/general.sh"

use() {
  while [ $# -gt 0 ]; do
    case $1 in
      constants) shellspec_constants ;;
      *) shellspec_proxy "$1" "shellspec_$1" ;;
    esac
    shift
  done
}

load() {
  while [ "$#" -gt 0 ]; do
    shellspec_source "${SHELLSPEC_LIB:-./lib}/libexec/$1.sh"
    shift
  done
}

unixtime() {
  IFS=" $IFS"
  #shellcheck disable=SC2046
  set -- $("$SHELLSPEC_DATE" -u +'%Y %m %d %H %M %S') "$1"
  IFS=${IFS# }
  set -- "$1" "${2#0}" "${3#0}" "${4#0}" "${5#0}" "${6#0}" "$7"
  [ "$2" -lt 3 ] && set -- $(( $1-1 )) $(( $2+12 )) "$3" "$4" "$5" "$6" "$7"
  set -- $(( 365*$1 + $1/4 - ($1/100) + $1/400 )) "$2" "$3" "$4" "$5" "$6" "$7"
  set -- "$1" $(( (306 * ($2 + 1) / 10) - 428 )) "$3" "$4" "$5" "$6" "$7"
  set -- $(( ($1 + $2 + $3 - 719163) * 86400 + $4 * 3600 + $5 * 60 + $6 )) "$7"
  eval "$2=$1"
}

is_specfile() {
  shellspec_match "${1%%:*}" "$SHELLSPEC_PATTERN"
}

found_specfile() {
  set -- "$1" "${2#./}"
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
    done < "$SHELLSPEC_INFILE" &&:
  else
    eval shellspec_find_files found_ ${1+'"$@"'}
  fi
}

edit_in_place() {
  if [ -e "$1" ]; then
    eval 'shift; putsn "$("$@" < "'"$1"'")" > "'"$1"'"'
  fi
}

info() {
  IFS=" $IFS"
  if [ "$SHELLSPEC_COLOR" ]; then
    set -- '\033[36m%s\033[m\n' "${*:-}"
  else
    set -- '%s\n' "${*:-}"
  fi
  IFS=${IFS#?}
  "$SHELLSPEC_PRINTF" "$@"
}

warn() {
  IFS=" $IFS"
  if [ "$SHELLSPEC_COLOR" ]; then
    set -- '\033[33m%s\033[m\n' "${*:-}"
  else
    set -- '%s\n' "${*:-}"
  fi
  IFS=${IFS#?}
  "$SHELLSPEC_PRINTF" "$@" >&2
}

error() {
  IFS=" $IFS"
  if [ "$SHELLSPEC_COLOR" ]; then
    set -- '\033[1;31m%s\033[m\n' "${*:-}"
  else
    set -- '%s\n' "${*:-}"
  fi
  IFS=${IFS#?}
  "$SHELLSPEC_PRINTF" "$@" >&2
}

abort() {
  error "$@"
  exit 1
}

set_exit_status() {
  return "$1"
}

nap() {
  if [ "$SHELLSPEC_MSLEEP" ]; then
    sleep 0.1
  else
    sleep 0
  fi
}

sleep_wait() {
  while "$@"; do nap; done
}

sleep_wait_until() {
  until "$@"; do nap; done
}

signal() { kill -"$1" "$2"; }
if kill -s 0 $$ 2>/dev/null; then
  signal() { kill -s "$1" "$2"; }
  # workaround for posh 0.8.5. broken signal
  if [ "$SHELLSPEC_DEFECT_SIGNAL" ]; then
    kill() { env kill "$@"; }
  fi
fi

timeout() {
  sleep 0
  set -- "$(t=0; unixtime t; echo "$t")" "$@"
  while [ "$(t=0; unixtime t; echo "$t")" -le "$(($1 + $2))" ]; do
    ( shift 2; "$@" ) && return 0
    nap
  done
  return 0
}

read_quickfile() {
  set -- "$1" "${2:-}" "${3:-}"
  while eval "{ IFS= read -r $1 || [ \"\$$1\" ]; } &&:"; do
    eval "set -- \"\$@\" \"\${$1##*:}\" \"\${$1%:*}\""
    case $4 in (todo | fixed) [ "$3" ] && continue; esac
    eval "$1=\$5"
    [ "$2" ] && eval "$2=\$4"
    return 0
  done
  return 1
}

includes_path() {
  [ "$2" = "./" ] && return 0
  set -- "/${1%/}" "/${2%/}"
  while [ "$1" ]; do
    [ "$1" = "$2" ] && return 0
    set -- "${1%/*}" "$2"
  done
  return 1
}

# $1: @ID, $2: [:@IDs...]
match_quick_data_range() {
  set -- "${1%:*}" "${1#*:}" "$2:"
  while [ "$3" ] && set -- "$1" "$2" "${3#*:}" "${3%%:*}"; do
    case $4 in (@*)
      [ "$1" = "$4" ] || starts_with "$1" "$4-" && return 0
    esac
  done
  return 1
}

# $1: line of quick data (PATH:@ID), $2-: path[:IDs...]
match_quick_data() {
  set -- "$@" "$1"
  while [ $# -gt 2 ] && shift; do
    case $1 in (*:*)
      eval "includes_path \"\${$#%%:*}\" \"\${1%%:*}\" &&:" || continue
      eval "match_quick_data_range \"\${$##*:}\" \"\${1#*:}\" &&:" || continue
      return 0
    esac
    eval "includes_path \"\${$#%%:*}\" \"\$1\" &&:" || continue
    return 0
  done
  return 1
}

use puts putsn starts_with
