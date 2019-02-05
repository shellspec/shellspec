#shellcheck shell=sh disable=SC2004,SC2016

shellspec_import posix
shellspec_proxy putsn shellspec_putsn
shellspec_proxy unixtime shellspec_unixtime

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
    shellspec_reset_params '$line'
    eval "$SHELLSPEC_RESET_PARAMS"
    for name in "$@"; do
      case $name in (CMD | COMMAND) break; esac
      i=$(($i+1))
    done
    while IFS= read -r line; do
      eval "$SHELLSPEC_RESET_PARAMS"
      [ "$1" = "$$" ] && shift $i && line="$*" && break
    done
    line=${line#'{'"${self##*/}"'} '}
    echo "${line%% $self*}"
  } ||:
}

command_path() {
  case $1 in
    */*) [ -x "$1" ] && echo "$1" ;;
    *)
      command=$1
      shellspec_reset_params '$PATH' ':'
      eval "$SHELLSPEC_RESET_PARAMS"
      for p in "$@"; do
        [ -x "${p%/}/${command%% *}" ] && echo "${p%/}/$command" && break
      done
  esac
}
