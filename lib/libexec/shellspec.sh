#shellcheck shell=sh disable=SC2004,SC2016

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"
load binary
use abspath starts_with

read_options_file() {
  [ -e "$1" ] || return 0
  file="$1" parser=$2
  set --
  while IFS= read -r line || [ "$line" ]; do
    case $# in
      0) eval "set -- $line" ;;
      *) eval "set -- \"\$@\" $line" ;;
    esac
  done < "$file" &&:
  [ $# -eq 0 ] || "$parser" "$@"
}

enum_options_file() {
  callback=$1
  set -- ".shellspec" ".shellspec-local"
  [ "${HOME:-}" ] && set -- "$HOME/.shellspec" "$@"
  if [ "${XDG_CONFIG_HOME:-}" ]; then
    set -- "$XDG_CONFIG_HOME/shellspec/options" "$@"
  elif [ "${HOME:-}" ]; then
    set -- "$HOME/.config/shellspec/options" "$@"
  fi
  while [ $# -gt 0 ]; do
    "$callback" "$1"
    shift
  done
}

read_cmdline() {
  [ -e "$1" ] || return 0

  octal_dump < "$1" | (
    cmdline='' oct_bug=''
    [ "$("$SHELLSPEC_PRINTF" '\101' 2>/dev/null ||:)" = "A" ] || oct_bug=0

    while IFS= read -r line; do
      case $line in
        000) line="040" ;;
        1??) line="${oct_bug}${line}" ;;
      esac
      cmdline="${cmdline}\\${line}"
    done

    "$SHELLSPEC_PRINTF" "$cmdline"
  )
}

ps_command() {
  ps -f || ps
}

read_ps() {
  # shellcheck disable=SC2015
  ps_command 2>/dev/null | (
    IFS=" " pid=$1 p=0 c=0 _pid=''
    IFS= read -r line
    # shellcheck disable=SC2086
    set -- $line

    for name in "${@:-}"; do
      p=$(($p + 1))
      case $name in ([pP][iI][dD]) break; esac
    done

    for name in "${@:-}"; do
      case $name in ([cC][mM][dD] | [cC][oO][mM][mM][aA][nN][dD]) break; esac
      c=$(($c + 1))
    done

    while IFS= read -r line; do
      # shellcheck disable=SC2086
      set -- $line
      eval "_pid=\${$p:-}"
      [ "$_pid" = "$pid" ] && shift $c && line="$*" && break
    done

    # workaround for old busybox ps format
    case $line in (\{*) line=${line#*\} }; esac
    echo "$line"
  ) &&: ||:
}

current_shell() {
  self=$1 pid=$2

  cmdline=$(read_cmdline "/proc/$2/cmdline")
  [ "$cmdline" ] || cmdline=$(read_ps "$2")

  echo "${cmdline%% $self*}"
}

command_path() {
  if [ $# -lt 2 ]; then
    set -- "" "$1" "${PATH}${SHELLSPEC_PATHSEP}"
  else
    set -- "$1" "$2" "${PATH}${SHELLSPEC_PATHSEP}"
  fi

  case $2 in (*/*)
    [ -x "$2" ] || return 1
    [ "$1" ] && eval "$1=\"\$2\""
    return 0
  esac

  while [ "$3" ]; do
    set -- "$1" "$2" "${3#*$SHELLSPEC_PATHSEP}" "${3%%$SHELLSPEC_PATHSEP*}"
    [ -x "${4%/}/$2" ] || continue
    [ "$1" ] && eval "$1=\"\${4%/}/\$2\""
    return 0
  done
  return 1
}

is_path_in_project() {
  set -- "$1" "${2:-$SHELLSPEC_PROJECT_ROOT}"
  [ "$1" = "$2" ] || starts_with "$1" "${2%/}/"
}

separate_abspath_and_range() {
  case $3 in
    [a-zA-Z]:*)
      set -- "$1" "$2" "${3%%:*}" "${3#*:}"
      case $4 in
        *:*) set -- "$1" "$2" "$3:${4%%:*}" "${4#*:}" ;;
        *) set -- "$1" "$2" "$3:$4" "" ;;
      esac
      ;;
    *)
      case $3 in
        *:*) set -- "$1" "$2" "${3%%:*}" "${3#*:}" ;;
        *) set -- "$1" "$2" "$3" "" ;;
      esac
  esac
  eval "$1=\$3 $2=\$4"
}

check_range() {
  set -- "$1:"
  while [ "$1" ] && set -- "${1#*:}" "${1%%:*}"; do
    case $2 in
      @*) case ${2#@} in (*[!0-9-]*) return 1; esac ;;
      *) case $2 in (*[!0-9]*) return 1; esac ;;
    esac
  done
  return 0
}

random_seed() {
  # Prevent 32bit overflow
  while [ ${#2} -ge 10 ]; do
    set -- "$1" "${2#?}" "$3"
  done

  # Remove leading zeros
  until [ "${2#0}" = "$2" ]; do
    set -- "$1" "${2#0}" "$3"
  done

  # Poor random number is enough for seed
  eval "$1=$(( ($2 / ($3 % 79 + 1) + $3) % 100000))"
}

kcov_version() {
  command_path "$1" || return 1
  error=$( { "$1" --version >/dev/null; } 2>&1) || error="error"
  [ "$error" ] && return 0
  "$1" --version
}


kcov_version_number() {
  ver=${1:-0} && ver=${ver#"${ver%%[0-9]*}"} && ver=${ver%%[!0-9]*}
  echo "$ver"
}
