#shellcheck shell=sh disable=SC2016

: "${SHELLSPEC_SHELL_TYPE:=sh}" "${SHELLSPEC_SHELL_VERSION:=}"

shellspec_shell_info() {
  shellspec_shell_version bash BASH_VERSION && return 0
  shellspec_shell_version zsh  ZSH_VERSION  && return 0
  shellspec_shell_version yash YASH_VERSION && return 0
  shellspec_shell_version posh POSH_VERSION && return 0
  if shellspec_shell_version ksh KSH_VERSION; then
    case $SHELLSPEC_SHELL_VERSION in
      *MIRBSD*) SHELLSPEC_SHELL_TYPE=mksh ;;
      *PD\ KSH*) SHELLSPEC_SHELL_TYPE=pdksh ;;
    esac
    return 0
  fi
  if (eval ': "${.sh.version}"' 2>/dev/null); then
    eval 'SHELLSPEC_SHELL_VERSION=${.sh.version}'
    SHELLSPEC_SHELL_TYPE=ksh
    return 0
  fi
}

shellspec_shell_version() {
  eval "[ \${$2+x} ] &&:" || return 1
  SHELLSPEC_SHELL_TYPE=$1
  eval "SHELLSPEC_SHELL_VERSION=\${$2}"
}
shellspec_shell_info

shellspec_constants() {
  set -- "${1:-}"

  # shellcheck disable=SC2059
  eval "$(printf "
    ${1}SOH='\\001' ${1}STX='\\002' ${1}ETX='\\003' ${1}EOT='\\004'
    ${1}ENQ='\\005' ${1}ACK='\\006' ${1}BEL='\\007' ${1}BS='\\010'
    ${1}HT='\\011'  ${1}TAB='\\011' ${1}LF='\\012'  ${1}VT='\\013'
    ${1}FF='\\014'  ${1}CR='\\015'  ${1}SO='\\016'  ${1}SI='\\017'
    ${1}DLE='\\020' ${1}DC1='\\021' ${1}DC2='\\022' ${1}DC3='\\023'
    ${1}DC4='\\024' ${1}NAK='\\025' ${1}SYN='\\026' ${1}ETB='\\027'
    ${1}CAN='\\030' ${1}EM='\\031'  ${1}SUB='\\032' ${1}ESC='\\033'
    ${1}FS='\\034'  ${1}GS='\\035'  ${1}RS='\\036'  ${1}US='\\037'
  ")"
}
shellspec_constants SHELLSPEC_

if (set -eu --; : "$@") 2>/dev/null; then
  shellspec_proxy() { eval "$1() { $2 \"\$@\"; }"; }
else
  shellspec_proxy() {
    eval "$1() { case \$# in (0) $2 ;; (*) $2 \"\$@\" ;; esac; }"
  }
fi

shellspec_import() {
  shellspec_reset_params '"$1" $SHELLSPEC_LOAD_PATH' ':'
  eval "$SHELLSPEC_RESET_PARAMS"
  while [ $# -gt 1 ]; do
    shellspec_import_ "${2%/}/$1.sh" && return 0
    shellspec_import_ "${2%/}/$1/${1##*/}.sh" && return 0
    shellspec_splice_params $# 1 1
    eval "$SHELLSPEC_RESET_PARAMS"
  done
  shellspec_error "Import failed, '$1' not found"
}

# shellcheck disable=SC1090
shellspec_import_() { [ -e "$1" ] && . "$1"; }

if [ "$SHELLSPEC_SHELL_TYPE" = "zsh" ]; then
  shellspec_find_files() {
    if eval '[[ -o nonomatch ]]'; then
      shellspec_find_files_ "$@"
    else
      setopt nonomatch
      shellspec_find_files_ "$@"
      unsetopt nonomatch
    fi
  }
else
  shellspec_proxy shellspec_find_files shellspec_find_files_
fi
shellspec_find_files_() {
  eval "
    shift
    while [ \$# -gt 0 ]; do
      case \$1 in (*/[*]) shift; continue; esac
      if [ -d \"\$1\" ]; then
        shellspec_find_files__ \"$1\" \"\${1%/}\"
      else
        \"$1\" \"\$1\"
      fi
      shift
    done
  "
}
shellspec_find_files__() {
  eval "
    SHELLSPEC_IFSORIG=\$IFS
    IFS=''
    set -- \$2/*
    IFS=\$SHELLSPEC_IFSORIG
    if [ \$# -gt 0 ]; then shellspec_find_files_ \"$1\" \"\$@\"; fi
  "
}
# Workaround for posh 0.10.2. do not glob with set -u.
if [ "$(set -u; echo /*)" = '/*' ]; then
  shellspec_find_files__() {
    eval "
      SHELLSPEC_IFSORIG=\$IFS
      IFS=''
      case \$- in (*u*) set +u ;; esac
      set -- \$2/*
      set -u
      IFS=\$SHELLSPEC_IFSORIG
      if [ \$# -gt 0 ]; then shellspec_find_files_ \"$1\" \"\$@\"; fi
    "
  }
fi

# `echo` not has portability, and external 'printf' command is slow.
# Use shellspec_puts or shellspec_putsn replacement of 'echo'.
# Those commands output arguments as it. (not interpret -n and escape sequence)
case $SHELLSPEC_SHELL_TYPE in
  zsh | ksh | mksh | pdksh)
    # some version of above shell does not implement 'printf' as built-in.
    shellspec_puts() { IFS=" $IFS"; print -nr -- "${*:-}"; IFS="${IFS#?}"; }
    ;;
  posh)
    # posh does not implement 'printf' or 'print' as built-in.
    # shellcheck disable=SC2039
    shellspec_puts() {
      [ $# -eq 0 ] && return 0
      IFS=" $IFS"; set -- "$*"; IFS="${IFS#?}"
      [ "$1" = -n ] && echo -n - && echo -n n && return 0
      shellspec_reset_params '$1' "\\\\"
      eval "$SHELLSPEC_RESET_PARAMS"
      [ $# -gt 0 ] && echo -n "$1" && shift
      while [ $# -gt 0 ]; do echo -n "\\\\$1" && shift; done
    }
    ;;
  *) shellspec_puts() { IFS=" $IFS"; printf '%s' "$*"; IFS="${IFS#?}"; }
esac
shellspec_putsn() {
  IFS=" $IFS"; shellspec_puts "${*:-}$SHELLSPEC_LF"; IFS="${IFS#?}"
}

shellspec_error() { shellspec_putsn "$*" >&2; exit 1; }

shellspec_reset_params() {
  SHELLSPEC_RESET_PARAMS="
    SHELLSPEC_IFSORIG=\$IFS IFS=\"${2:-$IFS}\"
    set -- $1
    IFS=\$SHELLSPEC_IFSORIG
  "
  [ "$SHELLSPEC_SHELL_TYPE" = zsh ] || return 0
  eval '[[ -o shwordsplit ]]' && return 0
  SHELLSPEC_RESET_PARAMS="
    setopt shwordsplit
    $SHELLSPEC_RESET_PARAMS
    unsetopt shwordsplit
  "
}

# $1: number of params, $2: offset, $3: length, $4-: list
shellspec_splice_params() {
  SHELLSPEC_RESET_PARAMS='set --'
  if [ "$1" -lt "${2:-0}" ]; then
    shellspec_splice_params_step 1 "$1"
  else
    shellspec_splice_params_step 1 "${2:-0}"
  fi
  shellspec_splice_params_list "$@"
  shellspec_splice_params_step $((${2:-0} + ${3:-$1} + 1)) "$1"
}
shellspec_splice_params_step() {
  [ "$1" -le "$2" ] || return 0
  SHELLSPEC_RESET_PARAMS="$SHELLSPEC_RESET_PARAMS \"\${$1}\""
  shellspec_splice_params_step $(($1 + 1)) "$2"
}
shellspec_splice_params_list() {
  while [ $# -gt 3 ]; do
    SHELLSPEC_RESET_PARAMS="$SHELLSPEC_RESET_PARAMS \"\${$4}\"" && shift
  done
}

# $1: callback, $2-: parameters
shellspec_each() {
  if [ $# -gt 1 ]; then
    eval "shift; shellspec_each_ $1 1 \"\$@\""
  fi
}
shellspec_each_() {
  eval "$1 \"\${$(($2 + 2))}\" $2 $(($# - 2))"
  [ "$2" -lt "$(($# - 2))" ] || return 0
  eval "shift 2; shellspec_each_ $1 $(($2 + 1)) \"\$@\""
}

shellspec_find() {
  SHELLSPEC_RESET_PARAMS='set --'
  eval "shift; shellspec_find_ $1 1 \"\$@\""
}
shellspec_find_() {
  if eval "$1 \"\${$(($2 + 2))}\" $2 $(($#-2)) &&:"; then
    SHELLSPEC_RESET_PARAMS="$SHELLSPEC_RESET_PARAMS  \"\${$2}\""
  fi
  [ "$2" -lt "$(($# - 2))" ] || return 0
  eval "shift 2; shellspec_find_ $1 $(($2 + 1)) \"\$@\""
}

# $1: callback, $2: from, $3: to $4: step
shellspec_sequence() {
  if [ "$2" -lt "$3" ]; then
    shellspec_sequence_ "$1" "$2" "$3" "${4:-1}" -le
  else
    shellspec_sequence_ "$1" "$2" "$3" "${4:--1}" -ge
  fi
}
shellspec_sequence_() {
  eval "[ \"$2\" \"$5\" \"$3\" ] &&:" || return 0
  "$1" "$2"
  shellspec_sequence_ "$1" $(($2 + $4)) "$3" "$4" "$5"
}

shellspec_escape_quote() {
  eval "
    shellspec_reset_params '\$$1' \"'\"
    eval \"\$SHELLSPEC_RESET_PARAMS\"
    $1=''
    while [ \$# -gt 0 ]; do
      $1=\"\${$1}\${1}\"
      shift
      [ \$# -eq 0 ] || $1=\"\${$1}'\\''\"
    done
  "
}

shellspec_lines() {
  [ "${2:-}" ] || return 0
  shellspec_lines_ "$1" "${2%$SHELLSPEC_LF}" 1
}

shellspec_lines_() {
  "$1" "${2%%$SHELLSPEC_LF*}" "$3" || return 0
  case $2 in (*$SHELLSPEC_LF*)
    shellspec_lines_ "$1" "${2#*$SHELLSPEC_LF}" "$(($3 + 1))"
  esac
}

# $1: variable, $2: string, $3 N times
shellspec_padding() {
  eval "$1=''"
  shellspec_padding_ "$1" "$2" "$3"
}
shellspec_padding_() {
  [ "$3" -eq 0 ] && return 0
  eval "$1=\"\${$1:-}\$2\""
  shellspec_padding_ "$1" "$2" $(($3 - 1))
}

shellspec_includes() {
  case $1 in (*"$2"*) return 0 ;esac
  return 1
}

if [ "$SHELLSPEC_SHELL_TYPE" = "posh" ]; then
  # workaround for posh <= 0.12.6
  if ! shellspec_includes "abc[d]" "c[d]"; then
    shellspec_includes() {
      shellspec_includes_escape "$2"
      case $1 in (*$shellspec_v*) return 0 ;esac
      return 1
    }

    shellspec_includes_escape() {
      shellspec_v=${1:-}
      SHELLSPEC_IFSORIG=$IFS
      shellspec_includes_split '*'
      shellspec_includes_split '?'
      shellspec_includes_split '['
      IFS=$SHELLSPEC_IFSORIG
    }

    shellspec_includes_split() {
      IFS="$1"
      #shellcheck disable=SC2086
      set -- $shellspec_v'' # Trailing quote require for posh 0.10.2.
      [ $# -eq 0 ] && return 0
      case $shellspec_v in
        *[$IFS]) shellspec_includes_join "[$IFS]" "$@" ;;
        *)  shellspec_includes_join "[$IFS]" "$@"
            shellspec_v=${shellspec_v%???}
      esac
    }

    shellspec_includes_join() {
      shellspec_v=''
      eval "shift
        while [ \$# -gt 0 ]; do
          shellspec_v=\"\$shellspec_v\$1$1\"; shift
        done
      "
    }
  fi
fi

shellspec_passthrough() {
  while IFS= read -r shellspec_passthrough_buffer; do
    shellspec_putsn "$shellspec_passthrough_buffer"
  done
  if [ "$shellspec_passthrough_buffer" ]; then
    shellspec_puts "$shellspec_passthrough_buffer"
  fi
  unset shellspec_passthrough_buffer
}

shellspec_readfile() {
  eval "$1=''"
  # shellcheck disable=SC2034
  while IFS= read -r shellspec_buf; do
    eval "$1=\"\${$1}\$shellspec_buf$SHELLSPEC_LF\""
  done < "$2"
  eval "$1=\"\${$1}\$shellspec_buf\""
  unset shellspec_buf
}

shellspec_trim() {
  eval "
    while :; do
      case \${$1} in
        \\ * | \${SHELLSPEC_TAB}*) $1=\${$1#?} ;;
        *) break ;;
      esac
    done
  "
}
