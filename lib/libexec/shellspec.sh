#shellcheck shell=sh disable=SC2004,SC2016

# shellcheck source=lib/semver.sh
. "${SHELLSPEC_LIB:-./lib}/semver.sh"
# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"
load binary
use abspath starts_with escape_quote starts_with includes

pack() {
  eval "set -- \"\$1\" \"\$2\" \"\${$1}\""
  escape_quote "$1" "$2"
  eval "$1=\"\$3 '\${$1}'\""
}

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
  if [ "${HOME:-}" ]; then
    set -- "$HOME/.shellspec-options" "$@"

    # DEPRECATED: Remove loading the $HOME/.shellspec
    [ -e "$HOME/.shellspec-options" ] || set -- "$HOME/.shellspec" "$@"
  fi
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

is_wsl() {
  [ -r "$SHELLSPEC_PROC_VERSION" ] || return 1
  read -r proc_version < "$SHELLSPEC_PROC_VERSION"
  case $proc_version in
    *[Mm]icrosoft*) return 0 ;;
    *) return 1 ;;
  esac
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

setup_load_path() {
  set -- "$SHELLSPEC_REPORTERLIB" "$SHELLSPEC_LIB" "$SHELLSPEC_HELPERDIR"
  eval "set -- \"\$@\" $SHELLSPEC_LOAD_PATH"
  SHELLSPEC_LOAD_PATH=''
  while [ $# -gt 0 ]; do
    SHELLSPEC_LOAD_PATH="${1}${SHELLSPEC_PATHSEP}${SHELLSPEC_LOAD_PATH}"
    shift
  done
  SHELLSPEC_LOAD_PATH=${SHELLSPEC_LOAD_PATH%$SHELLSPEC_PATHSEP}
}

finddirs() {
  {
    if [ "${2:-}" ] && is_wsl; then
      # find -L is very slow on WSL
      finddirs_lssort "$@"
    else
      finddirs_find "$@" || finddirs_lssort "$@"
    fi
  } 2>/dev/null || finddirs_native "$@"
}

finddirs_native() {
  ( set +f +u
    [ "${ZSH_VERSION:-}" ] && setopt nonomatch
    cd "$1" || exit
    echo "."
    if [ "${2:-}" ]; then
      check() { [ ! -d "$i" ]; }
    else
      check() { [ ! -d "$i" ] || [ -L "$i" ]; }
    fi
    recursive() {
      pwd=$1 oldpwd=$PWD
      cd "$pwd" || exit
      set -- *
      cd "$oldpwd" || exit
      for i; do set -- "$@" "$pwd/$i"; shift; done
      for i; do
        check "$i" && continue
        i=${i#"$PWD"}
        echo "$i"
        recursive "$i"
      done
    }
    recursive .
  )
}

# finddirs_ls() {
#   ( cd "$1"
#     echo "."
#     # shellcheck disable=SC2012
#     ls -R ${2:+-L} . | while IFS= read -r line; do
#       case $line in (./*:)
#         echo "${line%:}"
#       esac
#     done
#   )
# }

# finddirs_lsgrep() {
#   ( cd "$1"
#     echo "."
#     # shellcheck disable=SC2010
#     ls -R ${2:+-L} . | grep '^\.*/.*:$' | while IFS= read -r line; do
#       echo "${line%:}"
#     done
#   )
# }

# finddirs_lssed() {
#   ( cd "$1"
#     echo "."
#     # shellcheck disable=SC2012
#     ls -R ${2:+-L} . | sed -n '/^\.*\/.*:$/ s/:$// p'
#   )
# }

finddirs_lssort() {
  ( cd "$1" || exit
    echo "."
    # shellcheck disable=SC2012,SC2153
    "$SHELLSPEC_LS" -R ${2:+-L} . | { export LC_ALL=C; "$SHELLSPEC_SORT"; } | {
      while IFS= read -r line; do
        case $line in (./*:) echo "${line%:}"; break; esac
      done
      while IFS= read -r line; do
        case $line in (./*:) echo "${line%:}"; continue; esac
        break
      done
    }
  )
}

finddirs_find() {
  ( cd "$1" || exit
    "$SHELLSPEC_FIND" ${2:+-L} . -name ".?*" -prune -o -type d -print
  )
}

includes_pathstar() {
  while [ $# -gt 0 ]; do
    starts_with "$1" "*/" && return 0
    starts_with "$1" "**/" && return 0
    shift
  done
  return 1
}

check_pathstar() {
  while [ "$1" ]; do
    if starts_with "$1" "*/" || starts_with "$1" "**/"; then
      set -- "${1#*/}"
      continue
    fi
    includes "$1" '*' && return 1
    return 0
  done
  return 1
}

expand_pathstar() {
  eval "$(shift 2 && expand_pathstar_create_matcher "$@")"
  # shellcheck disable=SC2034
  expand_pathstar=$(shift && expand_pathstar_retrive '|||' "$@")
  set -- "$IFS" "$expand_pathstar" "$1"
  expand_pathstar=$3
  IFS=$SHELLSPEC_LF
  eval "set -- \"\$1\" \${${ZSH_VERSION:+=}2}"
  IFS=$1
  while [ $# -gt 1 ] && shift; do
    expand_pathstar_matcher "${1%\|\|\|*}" || continue
    "$expand_pathstar" "${1%\|\|\|*}" "${1##*\|\|\|}"
  done
}

expand_pathstar_create_matcher() {
  echo "expand_pathstar_matcher() {"
  for arg; do
    pattern='' doublestar=''
    while :; do
      if starts_with "$arg" '**/'; then
        arg=${arg#*/} doublestar=1
      elif starts_with "$arg" '*/'; then
        arg=${arg#*/} pattern="${pattern}*/"
      else
        break
      fi
    done

    escape_quote arg "$arg"
    if [ "$doublestar" ]; then
      echo "  case \$1 in (${pattern}*)"
      echo "    [ \"\${1##*/}\" = '$arg' ] && return 0"
      echo "  esac"
    elif [ "$pattern" ]; then
      echo "  case \$1 in (${pattern}*)"
      echo "    [ \"\${1#$pattern}\" = '$arg' ] && return 0"
      echo "  esac"
    else
      echo "  [ \"\$1\" = '$arg' ] && return 0"
    fi
    echo ""
  done
  echo "  return 1"
  echo "}"
}

expand_pathstar_retrive() {
  finddirs "$2" ${SHELLSPEC_DEREFERENCE:+follow} | (
    sep=$1 dir=${2%"${2##*[!/]}"}
    [ "$dir" = "." ] && dir="" || dir="$dir/"
    shift 2
    for i; do
      pattern=$i
      if starts_with "$i" "*/" || starts_with "$i" "**/"; then
        while i=${i#*/}; do
          starts_with "$i" "*/" && continue
          starts_with "$i" "**/" && continue
          break
        done
        set -- "$@" "${i}${sep}${pattern}"
      else
        echo "${i}${sep}"
      fi
      shift
    done
    while IFS= read -r line; do
      [ "$line" = "." ] && line="$dir" || line="${dir}${line#./}/"
      for i; do
        echo "${line}${i}"
      done
    done
  ) | "$SHELLSPEC_SORT"
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
