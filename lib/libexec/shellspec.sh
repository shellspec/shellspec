#shellcheck shell=sh disable=SC2004,SC2016

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"
use reset_params

read_dot_file() {
  [ "$1" ] || return 0
  [ -e "$1/$2" ] || return 0
  file="$1/$2" parser=$3
  set --
  while IFS= read -r line || [ "$line" ]; do
    if [ $# -eq 0 ]; then
      eval "set -- $line"
    else
      eval "set -- \"\$@\" $line"
    fi
  done < "$file"
  [ $# -eq 0 ] || "$parser" "$@"
}

process() {
  ps -f 2>/dev/null
}

read_cmdline() {
  [ -e "$1" ] || return 0

  printf_octal_bug=''
  [ "$(printf '\101' 2>/dev/null ||:)" = "A" ] || printf_octal_bug=0

  {
    # busybox 1.1.3: `-A n`, `-t o1` not supported
    # busybox 1.10.2: `od -b` not working properly
    od -t o1 -v "$1" 2>/dev/null || od -b -v "$1"
  } | while IFS= read -r cmdline; do
    case $cmdline in (*\ *) ;; (*) continue; esac
    eval "set -- ${cmdline#* }"
    cmdline=''
    for i in "$@"; do
      case $i in
        000) i="040" ;;
        1??) i="$printf_octal_bug$i" ;;
      esac
      cmdline="$cmdline\\$i"
      shift
    done
    #shellcheck disable=SC2059
    printf "$cmdline"
  done
}

read_ps() {
  pid=$1 p=0 c=0 _pid=''

  process | {
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
      eval "_pid=\${$p}"
      [ "$_pid" = "$pid" ] && shift $c && line="$*" && break
    done
    # workaround for old busybox ps format
    case $line in (\{*) line=${line#*\} }; esac
    echo "$line"
  } ||:
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
    */*) [ -x "${1%% *}" ] && echo "$1" ;;
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
