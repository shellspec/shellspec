#shellcheck shell=sh disable=SC2016

: "${SHELLSPEC_SHELL_TYPE:=}" "${SHELLSPEC_SHELL_VERSION:=}"
SHELLSPEC_SH_VERSION=$(eval 'echo "${.sh.version}"' 2>/dev/null) ||:
: "${SHELLSPEC_SH_VERSION:=${SH_VERSION:-}}"
: "${SHELLSPEC_SH_VERSION:=${NETBSD_SHELL:-}}"

shellspec_shell_info() {
  SHELLSPEC_SHELL_TYPE='sh'
  shellspec_shell_version bash BASH_VERSION && return 0
  shellspec_shell_version zsh  ZSH_VERSION  && return 0
  shellspec_shell_version yash YASH_VERSION && return 0
  shellspec_shell_version posh POSH_VERSION && return 0
  if shellspec_shell_version ksh KSH_VERSION; then
    case $SHELLSPEC_SHELL_VERSION in
      *MIRBSD* ) SHELLSPEC_SHELL_TYPE=mksh ;;
      *LEGACY* ) SHELLSPEC_SHELL_TYPE=lksh ;;
      *PD\ KSH*) SHELLSPEC_SHELL_TYPE=pdksh ;;
    esac
  else
    SHELLSPEC_SHELL_VERSION=$SHELLSPEC_SH_VERSION
    case $SHELLSPEC_SHELL_VERSION in
      *BUILD*  ) SHELLSPEC_SHELL_TYPE="sh" ;;
      *PD\ KSH*) SHELLSPEC_SHELL_TYPE="pdksh" ;;
      *pbosh*  ) SHELLSPEC_SHELL_TYPE="pbosh" ;;
      *bosh*   ) SHELLSPEC_SHELL_TYPE="bosh" ;;
      ?*       ) SHELLSPEC_SHELL_TYPE="ksh" ;;
    esac
  fi
}

shellspec_shell_version() {
  SHELLSPEC_SHELL_TYPE='sh' SHELLSPEC_SHELL_VERSION=''
  eval "[ \${$2+x} ] &&:" || return 1
  eval "SHELLSPEC_SHELL_TYPE=\$1 SHELLSPEC_SHELL_VERSION=\${$2}"
}

shellspec_shell_info

shellspec_constants() {
  set -- "${1:-}"

  SHELLSPEC_EVAL="
    ${1}SOH='\\001' ${1}STX='\\002' ${1}ETX='\\003' ${1}EOT='\\004' \
    ${1}ENQ='\\005' ${1}ACK='\\006' ${1}BEL='\\007' ${1}BS='\\010' \
    ${1}HT='\\011'  ${1}TAB='\\011' ${1}LF='\\012'  ${1}VT='\\013' \
    ${1}FF='\\014'  ${1}CR='\\015'  ${1}SO='\\016'  ${1}SI='\\017' \
    ${1}DLE='\\020' ${1}DC1='\\021' ${1}DC2='\\022' ${1}DC3='\\023' \
    ${1}DC4='\\024' ${1}NAK='\\025' ${1}SYN='\\026' ${1}ETB='\\027' \
    ${1}CAN='\\030' ${1}EM='\\031'  ${1}SUB='\\032' ${1}ESC='\\033' \
    ${1}FS='\\034'  ${1}GS='\\035'  ${1}RS='\\036'  ${1}US='\\037' \
    "
  # shellcheck disable=SC2059
  eval "$("$SHELLSPEC_PRINTF" "$SHELLSPEC_EVAL")"

  # Workaround: Variable CR is empty on MSYS
  if eval "[ \${#${1}CR} -eq 0 ] &&:"; then
    set -- "$1" "$("$SHELLSPEC_PRINTF" '\015_')"
    eval "${1}CR=\${2%_}"
  fi
}

shellspec_constants SHELLSPEC_
# shellcheck disable=SC2153,SC2034
SHELLSPEC_IFS=" ${SHELLSPEC_TAB}${SHELLSPEC_LF}"

if [ "$SHELLSPEC_DEFECT_EMPTYPARAMS" ]; then
  shellspec_proxy() {
    eval "$1() { case \$# in (0) $2 ;; (*) $2 \"\$@\" ;; esac; }"
  }
else
  shellspec_proxy() {
    eval "$1() { $2 \"\$@\"; }"
  }
fi

shellspec_import() {
  shellspec_find_module "$SHELLSPEC_LOAD_PATH" "$1" "SHELLSPEC_SOURCE"
  shift
  if [ $# -eq 0 ]; then
    shellspec_source "$SHELLSPEC_SOURCE"
  else
    shellspec_source "$SHELLSPEC_SOURCE" "$@"
  fi
}

shellspec_resolve_module_path() {
  shellspec_find_module "$SHELLSPEC_LOAD_PATH" "$2" "$1"
}

shellspec_module_exists() {
  set -- "$1" "${2:-$SHELLSPEC_LOAD_PATH}"
  [ -e "${2%%$SHELLSPEC_PATHSEP*}/$1.sh" ] && return 0
  [ -e "${2%%$SHELLSPEC_PATHSEP*}/$1/$1.sh" ] && return 0
  case $2 in (*$SHELLSPEC_PATHSEP*)
    shellspec_module_exists "$1" "${2#*$SHELLSPEC_PATHSEP}" &&:
    return $?
  esac
  return 1
}

shellspec_find_module() {
  if [ -e "${1%%$SHELLSPEC_PATHSEP*}/$2.sh" ]; then
    eval "$3=\${1%%\$SHELLSPEC_PATHSEP*}/\$2.sh"
    return 0
  fi
  if [ -e "${1%%$SHELLSPEC_PATHSEP*}/$2/$2.sh" ]; then
    eval "$3=\${1%%\$SHELLSPEC_PATHSEP*}/\$2/\$2.sh"
    return 0
  fi
  case $1 in (*$SHELLSPEC_PATHSEP*)
    shellspec_find_module "${1#*$SHELLSPEC_PATHSEP}" "$2" "$3"
    return 0
  esac
  shellspec_error "The required module '$2' is not found in SHELLSPEC_LOAD_PATH."
}

shellspec_source() {
  SHELLSPEC_SOURCE=$1
  shift
  # shellcheck disable=SC1090
  . "$SHELLSPEC_SOURCE"
}

if [ "${ZSH_VERSION:-}" ]; then
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
  SHELLSPEC_EVAL="
    shift; \
    while [ \$# -gt 0 ]; do \
      case \$1 in (*/[*]) shift; continue; esac; \
      if [ -d \"\$1\" ]; then \
        shellspec_find_files__ \"$1\" \"\${1%/}\"; \
      else \
        \"$1\" \"\$1\"; \
      fi; \
      shift; \
    done \
  "
  eval "$SHELLSPEC_EVAL"
}
shellspec_find_files__() {
  SHELLSPEC_EVAL="
    SHELLSPEC_IFSORIG=\$IFS; IFS=''; set -- \$2/*; IFS=\$SHELLSPEC_IFSORIG; \
    if [ \$# -gt 0 ]; then shellspec_find_files_ \"$1\" \"\$@\"; fi
  "
  eval "$SHELLSPEC_EVAL"
}
# Workaround for posh 0.10.2. do not glob with set -u.
if [ "${POSH_VERSION:-}" ] && [ "$(set -u; echo /*)" = '/*' ]; then
  shellspec_find_files__() {
    SHELLSPEC_EVAL="
      SHELLSPEC_IFSORIG=\$IFS; IFS=''; \
      case \$- in (*u*) set +u ;; esac; \
      set -- \$2/*; set -u; IFS=\$SHELLSPEC_IFSORIG; \
      if [ \$# -gt 0 ]; then shellspec_find_files_ \"$1\" \"\$@\"; fi \
    "
    eval "$SHELLSPEC_EVAL"
  }
fi

shellspec_printf() {
  eval '"$SHELLSPEC_PRINTF"' ${1+'"$@"'}
}

# `echo` not has portability, and external 'printf' command is slow.
# Use shellspec_puts or shellspec_putsn replacement of 'echo'.
# Those commands output arguments as it. (not interpret -n and escape sequence)
shellspec_puts() {
  [ "$SHELLSPEC_BUILTIN_PRINTF" ] && return 0
  if [ "$SHELLSPEC_BUILTIN_PRINT" ]; then
    [ "${ZSH_VERSION:-}" ] && return 1 || return 2
  fi
  if [ "${POSH_VERSION:-}" ]; then
    [ "${1#*\\}" ] && return 3 || return 4
  fi
  return 9
}
shellspec_puts "\\" &&:
case $? in
  0 | 9)
    # Use built-in or external 'printf'.
    shellspec_puts() {
      IFS=" $IFS"; "$SHELLSPEC_PRINTF" '%s' "${*:-}"; IFS=${IFS#?}
    }
    shellspec_putsn() {
      IFS=" $IFS"; "$SHELLSPEC_PRINTF" '%s\n' "${*:-}"; IFS=${IFS#?}
    }
    ;;
  1)
    # zsh 3.1.9, 4.0.4
    shellspec_puts() { builtin print -nr -- "${@:-}"; }
    shellspec_putsn() { builtin print -r -- "${@:-}"; }
    ;;
  2)
    # ksh88, mksh (depends on compile option), OpenBSD ksh (loksh, oksh), pdksh
    shellspec_puts() { command print -nr -- "${@:-}"; }
    shellspec_putsn() { command print -r -- "${@:-}"; }
    ;;
  3)
    # posh 0.3.14, 0.5.4 + workaround for parameter expansion bug
    shellspec_puts() {
      if [ $# -eq 1 ] && [ "$1" = "-n" ]; then
        builtin echo -n -; builtin echo -n n; return 0
      fi
      IFS=" $IFS"; set -- "${*:-}\\" ""; IFS=${IFS#?}
      while [ "$1" ]; do set -- "${1#*\\\\}" "$2${2:+\\\\}${1%%\\\\*}"; done
      builtin echo -n "$2"
    }
    shellspec_putsn() { [ $# -gt 0 ] && shellspec_puts "$@"; builtin echo; }
    ;;
  4)
    # posh
    shellspec_puts() {
      if [ $# -eq 1 ] && [ "$1" = "-n" ]; then
        builtin echo -n -; builtin echo -n n; return 0
      fi
      IFS=" $IFS"; set -- "${*:-}\\" ""; IFS=${IFS#?}
      while [ "$1" ]; do set -- "${1#*\\}" "$2${2:+\\\\}${1%%\\*}"; done
      builtin echo -n "$2"
    }
    shellspec_putsn() { [ $# -gt 0 ] && shellspec_puts "$@"; builtin echo; }
    ;;
esac

shellspec_error() { shellspec_putsn "$*" >&2; exit 1; }

# $1: callback, $2-: parameters
shellspec_each() {
  [ $# -gt 1 ] || return 0
  eval "shift; shellspec_each_ $1 1 \"\$@\""
}
shellspec_each_() {
  eval "$1 \"\${$(($2 + 2))}\" $2 $(($# - 2))"
  [ "$2" -lt "$(($# - 2))" ] || return 0
  eval "shift 2; shellspec_each_ $1 $(($2 + 1)) \"\$@\""
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

shellspec_loop() {
  [ "$2" -gt 0 ] || return 0
  "$1"
  shellspec_loop "$1" $(($2 - 1))
}

shellspec_get_line() {
  [ "$2" -le 0 ] && set -- "$1" "$2" ""
  while [ "$2" -gt 1 ]; do
    case $3 in
      *$SHELLSPEC_LF*) set -- "$1" $(($2 - 1)) "${3#*$SHELLSPEC_LF}" ;;
      *) set -- "$1" "$2" "" && break
    esac
  done
  [ "$3" ] && eval "$1=\${3%%\$SHELLSPEC_LF*}" && return 0
  unset "$1" ||:
}

shellspec_count_lines() {
  set -- "$1" "$2" 0
  while [ "$2" ]; do
    case $2 in
      *$SHELLSPEC_LF*) set -- "$1" "${2#*$SHELLSPEC_LF}" $(($3 + 1)) ;;
      *) set -- "$1" "$2" $(($3 + 1)) && break
    esac
  done
  eval "$1=\$3"
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

shellspec_wrap() {
  [ ! "$2" ] && eval "$1=" && return 0
  case $2 in
    *"$SHELLSPEC_LF") set -- "$1" "$2" "${3:-}" "${4:-}" "" "" ;;
    *) set -- "$1" "$2${SHELLSPEC_LF}" "${3:-}" "${4:-}" "" x ;;
  esac
  while [ "$2" ]; do
    set -- "$1" "${2#*$SHELLSPEC_LF}" "$3" "$4" \
      "$5$3${2%%$SHELLSPEC_LF*}$4${SHELLSPEC_LF}" "$6"
  done
  [ "$6" ] && set -- "$1" "$2" "$3" "$4" "${5%$SHELLSPEC_LF}"
  eval "$1=\$5"
}

shellspec_readfile() {
  set -- "$1" "$2" ""
  eval "$1="
  while IFS= read -r "$1"; do
    eval "set -- \"\$1\" \"\$2\" \"\$3\${$1}\$SHELLSPEC_LF\""
  done < "$2" &&:
  eval "$1=\"\$3\${$1}\""
}

shellspec_capturefile() {
  shellspec_readfile "$@"
  shellspec_chomp "$@"
}

shellspec_trim() {
  SHELLSPEC_EVAL="
    $1=\${2:-}; [ \"\$$1\" ] || return 0; \
    $1=\${$1#\"\${$1%%[!\$SHELLSPEC_IFS]*}\"}; \
    $1=\${$1%\"\${$1##*[!\$SHELLSPEC_IFS]}\"}
  "
  eval "$SHELLSPEC_EVAL"
}

# $1: ret, $2: from, $3: to
# $1: ret, $2: value, $3: from, $4: to
shellspec_replace_all_fast() {
  if [ $# -lt 4 ]; then
    eval "$1=\${$1//\"\$2\"/\"\$3\"}"
  else
    eval "$1=\${2//\"\$3\"/\"\$4\"}"
  fi
}

# $1: ret, $2: from, $3: to
# $1: ret, $2: value, $3: from, $4: to
shellspec_replace_all_posix() {
  if [ $# -lt 4 ]; then
    eval "set -- \"\$1\" \"\${$1}\" \"\$2\" \"\$3\" \"\""
  else
    set -- "$1" "$2" "$3" "$4" ""
  fi
  until [ _"$2" = _"${2#*"$3"}" ] && eval "$1=\$5\$2"; do
    set -- "$1" "${2#*"$3"}" "$3" "$4" "$5${2%%"$3"*}$4"
  done
}

# $1: ret, $2: from, $3: to
# $1: ret, $2: value, $3: from, $4: to
shellspec_replace_all_fallback() {
  [ $# -lt 4 ] && eval "set -- \"\$1\" \"\${$1}\" \"\$2\" \"\$3\""
  shellspec_meta_escape "$1" "$3"
  eval "set -- \"\$1\" \"\$2\" \"\${$1}\" \"\$4\" \"\""
  until eval "[ _\"\$2\" = _\"\${2#*$3}\" ] && $1=\$5\$2"; do
    eval "set -- \"\$1\" \"\${2#*$3}\" \"\$3\" \"\$4\" \"\$5\${2%%$3*}\$4\""
  done
}

shellspec_includes_posix() {
  case $1 in (*"$2"*) ;; (*) false ;; esac
}

shellspec_starts_with_posix() {
  case $1 in ("$2"*) ;; (*) false ;; esac
}

shellspec_ends_with_posix() {
  case $1 in (*"$2") ;; (*) false ;; esac
}

# shellcheck disable=SC2154
shellspec_includes_fallback() {
  shellspec_meta_escape shellspec_includes_fallback "$2"
  eval "[ ! \"\${1#*$shellspec_includes_fallback}\" = \"\$1\" ] &&:" &&:
}

# shellcheck disable=SC2154
shellspec_starts_with_fallback() {
  shellspec_meta_escape shellspec_starts_with_fallback "$2"
  eval "[ ! \"\${1#$shellspec_starts_with_fallback*}\" = \"\$1\" ] &&:" &&:
}

# shellcheck disable=SC2154
shellspec_ends_with_fallback() {
  shellspec_meta_escape shellspec_ends_with_fallback "$2"
  eval "[ ! \"\${1%*$shellspec_ends_with_fallback}\" = \"\$1\" ] &&:" &&:
}

shellspec_meta_escape() {
  # shellcheck disable=SC1003
  if [ "${1#*\?}" ]; then
    # posh <= 0.5.4
    set -- '\\\\:\\\\\\\\' '\\\[:[[]' '\\\?:[?]' '\\\*:[*]' '\\\$:[$]'
  elif [ "${2%%\\*}" ]; then
    # bosh = all (>= 20181007), busybox <= 1.22.0
    set -- '\\\\:\\\\\\\\' '\[:[[]' '\?:[?]' '\*:[*]' '\$:[$]'
  else
    # POSIX compliant
    set -- '\\:\\\\' '\[:[[]' '\?:[?]' '\*:[*]' '\$:[$]' '\#:[#]' '\~:[~]'
  fi

  set "$@" '\(:\\(' '\):\\)' '\|:\\|' '\":\\\"' '\`:\\\`' '\{:\\{' '\}:\\}' \
    "\\':\\\\'" '\ :\\ ' '\&:\\&' '\=:\\=' '\<:\\<' '\>:\\>' '\;:\\;' '\^:\\^'\
    '${SHELLSPEC_LF}:\${SHELLSPEC_LF}' '${SHELLSPEC_TAB}:\${SHELLSPEC_TAB}' \
    '${SHELLSPEC_CR}:\${SHELLSPEC_CR}' '${SHELLSPEC_VT}:\${SHELLSPEC_VT}' end

  echo 'shellspec_meta_escape() { set -- "$1" "$2" ""'
  until [ "$1" = "end" ] && shift && "$SHELLSPEC_PRINTF" '%s\n' "$@"; do
    set -- "${1%:*}" "${1#*:}" "$@"
    set -- "$@" 'until [ _"$2" = _"${2#*'"$1"'}" ] && set -- "$1" "$3$2" ""; do'
    set -- "$@" '  set -- "$1" "${2#*'"$1"'}" "$3${2%%'"$1"'*}'"$2"'"'
    set -- "$@" 'done'
    shift 3
  done
  echo 'eval "$1=\"\$2\""; }'
}
eval "$(shellspec_meta_escape "a?" "\\")"

shellspec_replace_all() {
  (eval 'v="*#*/" p="#*/"; [ "${v//"$p"/-}" = "*-" ]') 2>/dev/null && return 0
  [ "${1#"$2"}" = "a*b" ] && return 1 || return 2
}
eval 'shellspec_replace_all "a*b" "a[*]" &&:' &&:
case $? in
  0)
    # Fast version (Not POSIX compliant)
    # ash(busybox)>=1.30.1, bash>=3.1.17, dash>=none, ksh>=93?, mksh>=54
    # yash>=?, zsh>=?, pdksh=none, posh=none, bosh=none
    shellspec_replace_all() { shellspec_replace_all_fast "$@"; }
    shellspec_includes() { shellspec_includes_posix "$@"; }
    shellspec_starts_with() { shellspec_starts_with_posix "$@"; }
    shellspec_ends_with() { shellspec_ends_with_posix "$@"; }
    ;;
  1)
    # POSIX version (POSIX compliant)
    # ash(busybox)>=1.1.3, bash>=2.05b, dash>=0.5.2, ksh>=93q, mksh>=40
    # yash>=2.30?, zsh>=3.1.9?, pdksh=none, posh=none, bosh>=2020/04/27
    shellspec_replace_all() { shellspec_replace_all_posix "$@"; }
    shellspec_includes() { shellspec_includes_posix "$@"; }
    shellspec_starts_with() { shellspec_starts_with_posix "$@"; }
    shellspec_ends_with() { shellspec_ends_with_posix "$@"; }
    ;;
  2)
    # Fallback version
    shellspec_replace_all() { shellspec_replace_all_fallback "$@"; }
    shellspec_includes() { shellspec_includes_fallback "$@"; }
    shellspec_starts_with() { shellspec_starts_with_fallback "$@"; }
    shellspec_ends_with() { shellspec_ends_with_fallback "$@"; }
esac

# $2: pattern should be escaped
shellspec_match() {
  ( eval "export LC_ALL=C; case \${1:-} in ($2) :;; (*) false;; esac" ) &&:
}

shellspec_escape_quote() {
  [ $# -lt 2 ] && eval "set -- \"\$1\" \"\$${1}\""
  shellspec_replace_all "$1" "$2" "'" "'\"'\"'"
}

shellspec_pack() {
  SHELLSPEC_EVAL="
    $1=''; shift; \
    for $1; do \
      shellspec_escape_quote $1 \"\${$1}\"; \
      set -- \"\$@\" \"'\${$1}'\"; \
      shift; \
    done; \
    IFS=\" \$IFS\"; set -- \"\${*:-}\"; IFS=\${IFS#?}; unset $1; $1=\$1
  "
  eval "$SHELLSPEC_EVAL"
}

shellspec_match_pattern_escape() {
  shellspec_replace_all "$1" \\ \\\\
  shellspec_replace_all "$1" \" \\\"
  shellspec_replace_all "$1" \# \\\#
  shellspec_replace_all "$1" \$ \\\$
  shellspec_replace_all "$1" \& \\\&
  shellspec_replace_all "$1" \' \\\'
  shellspec_replace_all "$1" \( \\\(
  shellspec_replace_all "$1" \) \\\)
  shellspec_replace_all "$1" \; \\\;
  shellspec_replace_all "$1" \< \\\<
  shellspec_replace_all "$1" \> \\\>
  shellspec_replace_all "$1" \` \\\`
  shellspec_replace_all "$1" \~ \\\~
  shellspec_replace_all "$1" '=' '\='
  shellspec_replace_all "$1" '^' '\^'
  shellspec_replace_all "$1" ' ' '" "'
  shellspec_replace_all "$1" "$SHELLSPEC_TAB" '${SHELLSPEC_TAB}'
  shellspec_replace_all "$1" "$SHELLSPEC_LF" '${SHELLSPEC_LF}'
  shellspec_replace_all "$1" "$SHELLSPEC_CR" '${SHELLSPEC_CR}'
  shellspec_replace_all "$1" "$SHELLSPEC_VT" '${SHELLSPEC_VT}'
}

shellspec_match_pattern() {
  [ "${2:-}" ] || return 1
  shellspec_match_pattern=$2
  shellspec_match_pattern_escape shellspec_match_pattern
  set -- "$1" "$shellspec_match_pattern" /dev/null
  ( eval "export LC_ALL=C; case \$1 in ($2) :;; (*) false;; esac" ) 2>"$3" &&:
}

shellspec_join() {
  [ $# -le 3 ] && eval "$1=\${3:-}" && return 0
  SHELLSPEC_EVAL="
    $1=\$3 && shift 3; \
    while [ \$# -gt 0 ]; do $1=\"\${$1}$2\$1\" && shift; done \
  "
  eval "$SHELLSPEC_EVAL"
}

shellspec_shift10() {
  while [ "$3" -gt 0 ]; do
    case $2 in
      *.*)
        set -- "$1" "${2%.*}" "${2#*.}" "$3"
        set -- "$1" $(($2 * 10)) "${3%"${3#?}"}" "${3#?}" "$4"
        set -- "$1" "$(($2 + $3))${4:+.}$4" $(($5 - 1))
        ;;
      *) set -- "$1" $(($2 * 10)) $(($3 - 1))
    esac
  done

  while [ "$3" -lt 0 ]; do
    case $2 in
      *.*)
        set -- "$1" "${2%.*}" "${2#*.}" "$3"
        set -- "$1" "$(($2 / 10)).${2#"${2%?}"}$3" $(($4 + 1))
        ;;
      *) set -- "$1" "$(($2 / 10)).${2#"${2%?}"}" $(($3 + 1))
    esac
  done

  eval "$1=$2"
}

shellspec_chomp() {
  SHELLSPEC_EVAL="
    until case \$$1 in (*\$SHELLSPEC_LF) false; esac; do \
      $1=\${$1%\$SHELLSPEC_LF}; \
    done
  "
  eval "$SHELLSPEC_EVAL"
}

if [ "${ZSH_VERSION:-}" ]; then
  shellspec_get_nth() {
    set -- "$1" "$2" "${3#"${3%%[1-9]*}"}" "${4:-}" "$IFS"
    IFS=${4:-$SHELLSPEC_IFS}
    eval "set -- \"\$@\" \${=2}"
    IFS=$5
    [ $# -ge $(($3 + 5)) ] && eval "$1=\${$(($3 + 5))}"
  }
else
  shellspec_get_nth() {
    set -f -u -- "$1" "$2" "${3#"${3%%[1-9]*}"}" "${4:-}" "$IFS" "$-"
    IFS=${4:-$SHELLSPEC_IFS}
    # shellcheck disable=SC2086
    set -- "$@" $2
    IFS=$5
    [ "${6#*f}" = "$6" ] && set +f
    # Workaround for posh 0.10.2: glob does not expand when set -u
    [ "${6#*u}" = "$6" ] && set +u
    [ $# -ge $(($3 + 6)) ] && eval "$1=\${$(($3 + 6))} &&:"
  }
fi

shellspec_which() {
  set -- "$1" "${PATH%$SHELLSPEC_PATHSEP}${SHELLSPEC_PATHSEP}"
  while [ "${2%$SHELLSPEC_PATHSEP}" ]; do
    if [ -x "${2%%$SHELLSPEC_PATHSEP*}/$1" ]; then
      shellspec_putsn "${2%%$SHELLSPEC_PATHSEP*}/$1"
      return 0
    fi
    set -- "$1" "${2#*$SHELLSPEC_PATHSEP}"
  done
  return 1
}

shellspec_is_empty_file() {
  [ "${1:-}" ] && [ -f "${1:-}" ] && [ ! -s "${1:-}" ]
}

shellspec_is_empty_directory() {
  [ -d "$1" ] || return 1

  # This subshell is used to revert changes directory, variables and shell flags
  ( CDPATH=
    # set -- "$DIR"/* not working properly in posh 0.10.2
    cd "$1" || return 1

    # workaround for posh 0.10.2: glob does not expand when set -u
    set +o noglob +u
    # shellcheck disable=SC2039
    [ "${SHELLSPEC_FAILGLOB_AVAILABLE:-}" ] && shopt -u failglob
    [ "${SHELLSPEC_NOMATCH_AVAILABLE:-}" ] && setopt NO_NOMATCH

    for found in * .*; do
      case $found in (.|..) continue; esac
      [ -e "$found" ] && return 1
    done &&:
    return 0
  )
}

shellspec_pluralize() {
  [ $# -eq 2 ] && set -- "$1" "" "$2"
  [ "${3%% *}" ] || return 0
  [ "${3%% *}" -eq 1 ] && eval "$1=\${$1}\${2}\${3}\${4:-}" && return 0
  case $3 in
    *x) eval "$1=\${$1}\${2}\${3}es\${4:-}" ;;
    *) eval "$1=\${$1}\${2}\${3}s\${4:-}" ;;
  esac
}

shellspec_exists_file() {
  [ -e "$1" ]
}

shellspec_unsetf() {
  if shellspec_is_function "$1"; then
    # Workaround for posh.
    # Define function that run external command instead of unset function.
    # Unset the function cause not be able to run external command with posh.
    eval "$1() { case \$# in (0) command $1;; (*) command $1 \"\$@\"; esac; }"
    return 0
  fi
  if [ "$SHELLSPEC_BUILTIN_TYPESETF" ]; then
    # shellcheck disable=SC2039
    typeset -f "$1" >/dev/null 2>&1 || return 0
  elif [ "${POSH_VERSION:-}" ]; then
    ( unset -f "$1" 2>/dev/null ) || return 0
  fi
  unset -f "$1" 2>/dev/null ||:
  return 0
}

if [ "$SHELLSPEC_DEFECT_EXPORTP" ]; then
  shellspec_exportp() { export; }
else
  shellspec_exportp() { export -p; }
fi

shellspec_list_envkeys() {
  set -- "$1" "shellspec_list_envkeys"
  eval "$2_callback() { $1 \"\$@\"; }; $(shellspec_exportp | "$2_rework")" &&:
}
shellspec_list_envkeys_rework() {
  set -- printf '%s\n'
  while IFS= read -r line; do
    shellspec_list_envkeys_sanitize line "$line"
    set -- "$@" "shellspec_list_envkeys_parse $line || return \$?"
  done
  "$@"
}
shellspec_list_envkeys_parse() {
  while [ $# -gt 2 ]; do
    case $2 in
      *=*) break ;;
      *) shift ;;
    esac
  done
  [ $# -gt 1 ] && shift
  shellspec_list_envkeys_callback "${1%%[=]*}"
}

# Sanitize to avoid security risk when environment variable name
# contains meta characters
#
# e.g.
# $ env 'FOO; echo bad; # =aaa' ksh -c 'export -p | grep FOO'
# export FOO; echo bad; # =aaa
shellspec_list_envkeys_sanitize() {
  set -- "$IFS" "$1" "_$2_"
  IFS='!#&()*;<>?[]`{|}~'
  eval "set -- \"\$1\" \"\$2\" \${${ZSH_VERSION:+=}3}"
  IFS="_$1"
  eval "shift 2; $2=\"\$*\"; $2=\${$2%_}; $2=\${$2#_}"
  IFS=${IFS#_}
}

shellspec_exists_envkey() {
  (
    key="$1"
    callback() { [ ! "$1" = "$key" ] &&:; }
    shellspec_list_envkeys callback && return 1
    return 0
  ) &&:
}

shellspec_is_readonly() {
  eval "[ \"\${$1+x}\" ] &&:" || return 1
  eval "set -- \"\$1\" \"\${$1}\""
  ( eval "$1=_\$1 && [ ! \"\${$1}\" = \"\$2\" ]" ) 2>/dev/null && return 1
  return 0
}

shellspec_abspath() {
  case $PWD in
    [a-zA-Z]:* | //*) shellspec_abspath_win "$@" ;;
    *) shellspec_abspath_unix "$@" ;;
  esac
}

shellspec_abspath_unix() {
  case $2 in
    /*) set -- "$1" "$2/" "" "" ;;
    *) set -- "$1" "${3:-$PWD}/$2/" "" ""
  esac

  while [ "$2" ]; do
    case ${2%%/*} in
      "" | .) set -- "$1" "${2#*/}" "${2%%/*}" "$4" ;;
      ..) set -- "$1" "${2#*/}" "${2%%/*}" "${4%/*}" ;;
      *) set -- "$1" "${2#*/}" "${2%%/*}" "$4/${2%%/*}"
    esac
  done
  eval "$1=\"/\${4#/}\""
}

shellspec_chdrv() { cd "$1:" 2>/dev/null || exit; }

shellspec_abspath_win() {
  set -- "$1" "$2" "${3:-$PWD}"

  case $2 in (//*) # UNC path
    shellspec_abspath_unix "$1" "${2#/}"
    eval "$1=\"/\${$1}\""
    return 0
  esac

  case $2 in
    [a-zA-Z]:/*) set -- "$1" "/$2" ;;
    [a-zA-Z]:*)
      set -- "$1" "$2" "$(shellspec_chdrv "${2%%:*}" && echo "$3")"
      set -- "$1" "/${3%/}/${2#?:}" ;;
    /*) set -- "$1" "/${3%%:*}:$2" ;;
    *) set -- "$1" "/${3%/}/$2" ;;
  esac
  shellspec_abspath_unix "$@"
  eval "$1=\"\${$1#/}\""
}

shellspec_mv() { "$SHELLSPEC_MV" "$@"; }
shellspec_rm() { "$SHELLSPEC_RM" "$@"; }
shellspec_chmod() { "$SHELLSPEC_CHMOD" "$@"; }
shellspec_sleep() { "$SHELLSPEC_SLEEP" "$@"; }
