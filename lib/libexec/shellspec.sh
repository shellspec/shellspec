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

current_shell() {
  self=$1 i=0

  eval "${2:-ps w}" 2>/dev/null | {
    IFS= read -r line
    reset_params '$line'
    eval "$RESET_PARAMS"
    for name in "${@:-}"; do
      case $name in (CMD | COMMAND | Command) break; esac
      i=$(($i+1))
    done
    while IFS= read -r line; do
      eval "$RESET_PARAMS"
      [ "$1" = "$$" ] && shift $i && line="$*" && break
    done

    if [ "$line" ]; then
      line=${line#'{'"${self##*/}"'} '}
      echo "${line%% $self*}"
    else
      current_shell_fallback_on_linux "$self" "/proc/$$/cmdline"
    fi
  } ||:
}

current_shell_fallback_on_linux() {
  [ -f "$2" ] || return 0

  # "/proc/$$/cmdline" includes null character
  #   zsh: ${line%[$IFS]} is removing null character
  #   yash: () is workaround for #23 in contrib/bugs.sh
  #   busybox ash: read reads 'busyboxash'
  (
    IFS= read -r line < "$2" ||:
    line=${line%%$1*}
    line=${line%[$IFS]}
    case $line in (*/busybox* | busybox*)
      line="${line%busybox*}busybox ${line##*busybox}"
    esac
    echo "$line"
  )
}

command_path() {
  case $1 in
    */*) [ -x "${1%% *}" ] && echo "$1" ;;
    *)
      command=$1
      reset_params '$PATH' ':'
      eval "$RESET_PARAMS"
      for p in "$@"; do
        [ -x "${p%/}/${command%% *}" ] && echo "${p%/}/$command" && break
      done
  esac
}
