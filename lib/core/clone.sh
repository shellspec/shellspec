#shellcheck shell=sh

shellspec_clone_typeset() { eval typeset ${1+'"$@"'} 2>/dev/null; }
shellspec_clone_set() { set; }

shellspec_clone_escape() {
  set -- "$1" "$2'" ""
  while [ "$2" ]; do
    set -- "$1" "${2#*\'}" "$3${2%%\'*}'\''"
  done
  set -- "$1" "'${3%????}'"
  set -- "$1" "${2#\'\'}"
  set -- "$1" "${2%\'\'}"
  eval "$1=\"\$2\""
}

shellspec_clone_unset() {
  for shellspec_clone; do
    set -- "$@" "${1#*:}"
    shift
  done
  echo unset "$@" "||:"
}

shellspec_clone() {
  [ $# -gt 0 ] && shellspec_clone_unset "$@"
  while [ $# -gt 0 ]; do
    if eval "[ \"\${${1%%:*}+x}\" ] &&:"; then
      "shellspec_clone_$SHELLSPEC_CLONE_TYPE" "${1%%:*}" "${1#*:}" ||:
    fi
    shift
  done
}

# dash, busybox, bosh, posh
shellspec_clone_posix() {
  eval "shellspec_clone_escape shellspec_clone \"\${$1}\""
  shellspec_putsn "$2=$shellspec_clone"
}

# bash >= 2.03
shellspec_clone_bash() {
  shellspec_clone_typeset -p "$1" | {
    IFS= read -r shellspec_clone || return 1
    set -- "$shellspec_clone" "$1" "$2"
    shellspec_putsn "${1%%\ "$2="*} $3=${1#*\ "$2="}"
    while IFS= read -r shellspec_clone; do
      shellspec_putsn "$shellspec_clone"
    done
  }
}

# zsh >= 4.2.5
shellspec_clone_zsh() {
  shellspec_clone_typeset -g -p "$1" | {
    IFS= read -r shellspec_clone || return 1

    case $shellspec_clone in ("typeset "*)
      case ${shellspec_clone%%"="*} in (*" -g "*)
        shellspec_clone="${shellspec_clone%%\ -g\ *} ${shellspec_clone#*\ -g\ }"
      esac
    esac

    if [ "${shellspec_clone##*\ }" = "$1" ]; then
      set -- "$shellspec_clone" "$1" "$2"
      print -r -- "${1%\ "$2"} $3"
      IFS= read -r shellspec_clone || return 0
      print -r -- "$3=${shellspec_clone#"$2="}"
      while IFS= read -r shellspec_clone; do
        print -r -- "$shellspec_clone"
      done
      return 0
    fi

    set -- "$shellspec_clone" "$1" "$2"
    print -r -- "${1%%\ "$2="*} $3=${1#*\ "$2="}"
    while IFS= read -r shellspec_clone; do
      print -r -- "$shellspec_clone"
    done
  }
}

# ksh >= 93u, mksh >= R40
shellspec_clone_ksh() {
  shellspec_clone_typeset -p "$1" | {
    IFS= read -r shellspec_clone || return 1
    if [ "${shellspec_clone%%\ *}" = "set" ]; then
      print -r -- "${shellspec_clone%\ "$1"} $2"
      while IFS= read -r shellspec_clone; do
        print -r -- "${shellspec_clone%%\ "$1"*} $2${shellspec_clone#*\ "$1"}"
      done
      return 0
    fi

    case $shellspec_clone in
      "$1="*) print -r -- "$2=${shellspec_clone#"$1="}" ;;
      *"$1") print -r -- "${shellspec_clone%\ "$1"} $2" ;;
      *) print -r -- "${shellspec_clone%%"$1="*}$2=${shellspec_clone#*"$1="}"
    esac
    while IFS= read -r shellspec_clone; do
      print -r -- "$shellspec_clone"
    done
  }
}

# yash >= 2.29
shellspec_clone_yash() {
  shellspec_clone_typeset -p "$1" | {
    IFS= read -r shellspec_clone || return 1
    if [ "${shellspec_clone%%\ *}" = "typeset" ]; then
      set -- "$shellspec_clone" " $1" "$2"
      case $1 in
        *"$2") shellspec_putsn "${1%%"$2"} $3" ;;
        *) shellspec_putsn "${1%%"$2="*} $3=${1#*"$2="}" ;;
      esac
      shift 2
      while IFS= read -r shellspec_clone; do
        shellspec_putsn "$shellspec_clone"
      done
      return 0
    fi

    set -- "$2=${shellspec_clone#"$1="}" "$@"
    while IFS= read -r shellspec_clone; do
      shellspec_putsn "$1"
      shift
      set -- "$shellspec_clone" "$@"
    done
    shellspec_putsn "${1%%\ "$2"} $3"
  }
}

# zsh < 4.2.0
shellspec_clone_old_zsh() {
  shellspec_clone_typeset + | while IFS= read -r shellspec_clone; do
    [ ! "${shellspec_clone##* }" = "$1" ] && continue
    shellspec_clone=" $shellspec_clone"
    set -- "${shellspec_clone% *} " "$@"
    shellspec_clone="typeset"
    case $1 in (*' association '*)
      shellspec_clone="$shellspec_clone -A"
    esac
    case $1 in (*' float '*)
      eval "set -- \"\${$2}\" \"\$@\""
      case $1 in
        *e*) shellspec_clone="$shellspec_clone -E" ;;
        *) shellspec_clone="$shellspec_clone -F" ;;
      esac
      shift
    esac
    case $1 in (*' left justified '*)
      set -- "${1#* left justified }" "$@"
      shellspec_clone="$shellspec_clone -L ${1%% *}"
      shift
    esac
    case $1 in (*' right justified '*)
      set -- "${1#* right justified }" "$@"
      shellspec_clone="$shellspec_clone -R ${1%% *}"
      shift
    esac
    case $1 in (*' zero filled '*)
      set -- "${1#* zero filled }" "$@"
      shellspec_clone="$shellspec_clone -Z ${1%% *}"
      shift
    esac
    case $1 in (*' array '*)
      shellspec_clone="$shellspec_clone -a"
    esac
    case $1 in (*' integer '*)
      shellspec_clone="$shellspec_clone -i"
      eval "set -- \"\${$2}\" \"\$@\""
      case $1 in (*\#*)
        shellspec_clone="$shellspec_clone ${1%%\#*}"
      esac
      shift
    esac
    case $1 in (*' lowercase '*)
      shellspec_clone="$shellspec_clone -l"
    esac
    case $1 in (*' readonly '*)
      shellspec_clone="$shellspec_clone -r"
    esac
    case $1 in (*' tagged '*)
      shellspec_clone="$shellspec_clone -t"
    esac
    case $1 in (*' uppercase '*)
      shellspec_clone="$shellspec_clone -u"
    esac
    case $1 in (*' exported '*)
      shellspec_clone="$shellspec_clone -x"
    esac
    shift
    print -r -- "$shellspec_clone $2"

    shellspec_clone_typeset -g "$1" | {
      if IFS= read -r shellspec_clone; then
        print -r -- "$2=${shellspec_clone#"$1="}"
        while IFS= read -r shellspec_clone; do
          print -r -- "$shellspec_clone"
        done
      fi
    }
    break
  done
}

# ksh < 93u
shellspec_clone_old_ksh() {
  shellspec_clone_typeset +p | while IFS= read -r shellspec_clone; do
    [ ! "${shellspec_clone##* }" = "$1" ] && continue
    print -r -- "${shellspec_clone%\ "$1"} $2"
    break
  done
  shellspec_clone_set | while IFS= read -r shellspec_clone; do
    [ ! "${shellspec_clone%%[=[]*}" = "$1" ] && continue
    print -r -- "${2}${shellspec_clone#"$1"}"
  done
}

shellspec_clone_exists_variable() {
  case $1 in (*\[*) set -- "${1%%\[*}" "${1#*\[}"; esac
  case $1 in ([a-zA-Z_]*) ;; (*) return 1; esac
  case $1 in (*[!a-zA-Z_]*) return 1 ; esac
  if [ $# -gt 1 ]; then
    case $2 in (*\]) ;; (*) return 1; esac
    case ${2%\]} in (*[!0-9]*) return 1; esac
  fi
  set -- "$1${2:+[}${2:-}"
  eval "[ \${$1+x} ] &&:"
}

# pdksh, mksh < 40, OpenBSD ksh, loksh, ksh88
shellspec_clone_old_pdksh() {
  eval "[ \"\${${1%%:*}+x}\" ] &&:" || return 1
  shellspec_clone_typeset | while IFS= read -r shellspec_clone; do
    [ ! "${shellspec_clone##* }" = "$1" ] && continue
    print -r -- "${shellspec_clone% *} $2"
    break
  done
  shellspec_clone_set | while IFS= read -r shellspec_clone; do
    [ ! "${shellspec_clone%%[=[]*}" = "$1" ] && continue
    shellspec_clone=${shellspec_clone%%[=]*}
    shellspec_clone_exists_variable "$shellspec_clone" || continue
    set -- "${2}${shellspec_clone#"$1"}" "$@"
    eval "shellspec_clone_escape shellspec_clone \"\${$shellspec_clone}\""
    print -r -- "$1=$shellspec_clone"
    shift
  done
}
