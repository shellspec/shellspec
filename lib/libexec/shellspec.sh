#shellcheck shell=sh disable=SC2004,SC2016

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"
use reset_params join match
load binary

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

  octal_dump < "$1" | {
    cmdline='' printf_octal_bug=''
    [ "$(printf '\101' 2>/dev/null ||:)" = "A" ] || printf_octal_bug=0
    while IFS= read -r line; do
      case $line in
        000) line="040" ;;
        1??) line="$printf_octal_bug$line" ;;
      esac
      cmdline="$cmdline\\$line"
    done
    #shellcheck disable=SC2059
    printf "$cmdline"
  }
}

read_ps() {
  #shellcheck disable=SC2015
  ps -f 2>/dev/null | {
    IFS=" " pid=$1 p=0 c=0 _pid=''
    IFS= read -r line
    reset_params '$line'
    eval "$RESET_PARAMS"

    for name in "${@:-}"; do
      p=$(($p + 1))
      case $name in ([pP][iI][dD]) break; esac
    done

    for name in "${@:-}"; do
      case $name in ([cC][mM][dD] | [cC][oO][mM][mM][aA][nN][dD]) break; esac
      c=$(($c + 1))
    done

    while IFS= read -r line; do
      eval "$RESET_PARAMS"
      eval "_pid=\${$p:-}"
      [ "$_pid" = "$pid" ] && shift $c && line="$*" && break
    done

    # workaround for old busybox ps format
    case $line in (\{*) line=${line#*\} }; esac

    echo "$line"
  } &&: ||:
}

current_shell() {
  self=$1 pid=$2

  cmdline=$(read_cmdline "/proc/$2/cmdline")
  if [ -z "$cmdline" ]; then
    cmdline=$(read_ps "$2")
  fi

  echo "${cmdline%% $self*}"
}

command_path() {
  case $1 in
    */*) [ -x "${1%% *}" ] && echo "$1" && return 0 ;;
    *)
      command=$1
      reset_params '$PATH' ':'
      eval "$RESET_PARAMS"
      while [ $# -gt 0 ]; do
        [ -x "${1%/}/${command%% *}" ] && echo "${1%/}/$command" && return 0
        shift
      done
  esac
  return 1
}

check_range() {
  reset_params '$1' ':'
  eval "$RESET_PARAMS"
  while [ $# -gt 0 ]; do
    case $1 in
      @*) case ${1#@} in (*[!0-9-]*) return 1; esac ;;
      *) case $1 in (*[!0-9]*) return 1; esac ;;
    esac
    shift
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
  command_path "$SHELLSPEC_KCOV_PATH" >/dev/null || return 1
  version=$("$SHELLSPEC_KCOV_PATH" --version 2>/dev/null) || version=''
  echo "$version"
}

kcov_version_number() {
  ver=${1:-0} && ver=${ver#"${ver%%[0-9]*}"} && ver=${ver%%[!0-9]*}
  echo "$ver"
}
