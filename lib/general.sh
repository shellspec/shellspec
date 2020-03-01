#shellcheck shell=sh disable=SC2016

: "${SHELLSPEC_SHELL_TYPE:=}" "${SHELLSPEC_SHELL_VERSION:=}"
SHELLSPEC_SH_VERSION=$(eval 'echo "${.sh.version}"' 2>/dev/null) ||:

shellspec_shell_info() {
  SHELLSPEC_SHELL_TYPE='sh'
  shellspec_shell_version bash BASH_VERSION && return 0
  shellspec_shell_version zsh  ZSH_VERSION  && return 0
  shellspec_shell_version yash YASH_VERSION && return 0
  shellspec_shell_version posh POSH_VERSION && return 0
  if shellspec_shell_version ksh KSH_VERSION; then
    case $SHELLSPEC_SHELL_VERSION in
      *MIRBSD* ) SHELLSPEC_SHELL_TYPE=mksh ;;
      *PD\ KSH*) SHELLSPEC_SHELL_TYPE=pdksh ;;
    esac
  else
    SHELLSPEC_SHELL_VERSION=$SHELLSPEC_SH_VERSION
    case $SHELLSPEC_SHELL_VERSION in
      *pbosh*) SHELLSPEC_SHELL_TYPE=pbosh ;;
      *bosh* ) SHELLSPEC_SHELL_TYPE=bosh ;;
      ?*     ) SHELLSPEC_SHELL_TYPE=ksh ;;
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
  eval "$(printf "$SHELLSPEC_EVAL")"

  # Workaround: Variable CR is empty on MSYS
  if eval "[ \${#${1}CR} -eq 0 ] &&:"; then
    set -- "$1" "$(printf '\015')"
    eval "${1}CR=\$2"
  fi
}

shellspec_constants SHELLSPEC_
# shellcheck disable=SC2153,SC2034
SHELLSPEC_IFS=" ${SHELLSPEC_TAB}${SHELLSPEC_LF}"

if (set -eu --; : "$@") 2>/dev/null; then
  shellspec_proxy() {
    eval "$1() { $2 \"\$@\"; }"
  }
else
  shellspec_proxy() {
    eval "$1() { case \$# in (0) $2 ;; (*) $2 \"\$@\" ;; esac; }"
  }
fi

shellspec_import() {
  shellspec_import_deep "$SHELLSPEC_LOAD_PATH" "$1"
}

shellspec_import_deep() {
  shellspec_import_ "${1%%:*}" "$2" && return 0
  case $1 in
    *:*) shellspec_import_deep "${1#*:}" "$2" ;;
    *) shellspec_error "Import failed, '$2' not found" ;;
  esac
}

shellspec_import_() {
  if [ -e "$1/$2.sh" ]; then
    # shellcheck disable=SC1090
    . "$1/$2.sh"
    return 0
  fi
  if [ -e "$1/$2/$2.sh" ]; then
    # shellcheck disable=SC1090
    . "$1/$2/$2.sh"
    return 0
  fi
  return 1
}

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
case $SHELLSPEC_SHELL_TYPE in (posh)
  if [ "$(set -u; echo /*)" = '/*' ]; then
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
esac

# `echo` not has portability, and external 'printf' command is slow.
# Use shellspec_puts or shellspec_putsn replacement of 'echo'.
# Those commands output arguments as it. (not interpret -n and escape sequence)
case $SHELLSPEC_SHELL_TYPE in
  zsh | ksh | mksh | pdksh)
    # some version of above shell does not implement 'printf' as built-in.
    shellspec_puts() { IFS=" $IFS"; print -nr -- "${*:-}"; IFS=${IFS#?}; }
    ;;
  posh)
    # posh does not implement 'printf' or 'print' as built-in.
    # shellcheck disable=SC2039
    shellspec_puts() {
      [ $# -eq 0 ] && return 0
      IFS=" $IFS"; set -- "$*"; IFS=${IFS#?}
      [ "$1" = -n ] && echo -n - && echo -n n && return 0
      shellspec_reset_params '$1' "\\\\"
      eval "$SHELLSPEC_RESET_PARAMS"
      [ $# -gt 0 ] && echo -n "$1" && shift
      while [ $# -gt 0 ]; do echo -n "\\\\$1" && shift; done
    }
    ;;
  *)
    #shellcheck disable=SC2030,SC2123
    if ( PATH=; printf ) 2>/dev/null; then
      shellspec_puts() { IFS=" $IFS"; printf '%s' "$*"; IFS=${IFS#?}; }
    else
      #shellcheck disable=SC2031
      shellspec_puts() {
        # To work even if PATH is empty
        PATH="${PATH:-}:/usr/bin:/bin" IFS=" $IFS"
        printf '%s' "$*"
        PATH=${PATH%:/usr/bin:/bin} IFS=${IFS#?}
      }
    fi
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
  [ "${ZSH_VERSION:-}" ] || return 0
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
  shellspec_splice_params_step 1 "${2:-0}"
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

shellspec_loop() {
  if [ "$2" -gt 0 ]; then
    "$1"
    shellspec_loop "$1" $(($2 - 1))
  fi
}

shellspec_escape_quote() {
  SHELLSPEC_EVAL="
    [ $# -gt 1 ] && $1=\${2:-}; \
    shellspec_reset_params '\$$1' \"'\"; \
    eval \"\$SHELLSPEC_RESET_PARAMS\"; $1=''; \
    while [ \$# -gt 0 ]; do \
      $1=\"\${$1}\${1}\"; shift; \
      [ \$# -eq 0 ] || $1=\"\${$1}'\\''\"; \
    done \
  "
  eval "$SHELLSPEC_EVAL"
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

# workaround for posh
shellspec_escape_meta_posh() {
  eval "shellspec_escape_meta_posh=\$$1"
  set -- "$1" ""
  while [ "$shellspec_escape_meta_posh" ]; do
    # shellcheck disable=SC1003
    case $shellspec_escape_meta_posh in
      [*]*) set -- "$1" "$2[*]" ;;
      [?]*) set -- "$1" "$2[?]" ;;
      [[]*) set -- "$1" "$2[[]" ;;
      '\\'*) set -- "$1" "$2"'\\' ;;
      *) set -- "$1" \
          "$2${shellspec_escape_meta_posh%"${shellspec_escape_meta_posh#?}"}"
    esac
    shellspec_escape_meta_posh=${shellspec_escape_meta_posh#?}
  done
  eval "$1=\$2"
}

# shellcheck disable=SC2194
if case "a[d]" in (*"a[d]"*) false; esac; then
  # workaround for posh. ok: 0.13.0, 0.6.12 bad:0.12.6, 0.10.2, 0.8.5
  shellspec_includes() {
    shellspec_includes_pattern="$2"
    shellspec_escape_meta_posh shellspec_includes_pattern
    set -- "$1" "$shellspec_includes_pattern"
    case $1 in (*$2*) eval :; return 0; esac
    return 1
  }
else
  shellspec_includes() {
    # workaround for pdksh on debian 2.2, Memory fault without eval
    case $1 in (*"$2"*) eval :; return 0; esac
    return 1
  }
fi

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
  SHELLSPEC_EVAL="
    $1=\${2:-}; [ \"\$$1\" ] || return 0; \
    $1=\${$1#\"\${$1%%[!\$SHELLSPEC_IFS]*}\"}; \
    $1=\${$1%\"\${$1##*[!\$SHELLSPEC_IFS]}\"}
  "
  eval "$SHELLSPEC_EVAL"
}

shellspec_replace_posix() {
  eval "shellspec_replace_rest=\${$1} shellspec_replace=''"
  until case $shellspec_replace_rest in (*"$2"*) false; esac; do
    shellspec_replace=${shellspec_replace}${shellspec_replace_rest%%"$2"*}$3
    shellspec_replace_rest=${shellspec_replace_rest#*"$2"}
  done
  eval "$1=\$shellspec_replace\$shellspec_replace_rest"
}
shellspec_proxy shellspec_replace shellspec_replace_posix

# shellcheck disable=SC2194
if (eval 'v="*#*/" p="#*/"; [ "${v//"$p"/-}" = "*-" ]') 2>/dev/null; then
  # not posix compliant, but fast
  #
  # supported: bash, busybox ash, ksh93, mksh, yash, zsh
  #   but not work properly because of bug:
  #     bash: 2.03, 2.05a, 2.05b
  #     busybox ash: < 1.30.1(?)
  #     mksh: < R54(?)
  # not supported: ash, dash, ksh88, pdksh, posh
  shellspec_replace() {
    eval "$1=\${$1//\"\$2\"/\"\$3\"}"
  }
elif case "a[d]" in (*"a[d]"*) false; esac; then
  # workaround for posh <= 0.12.6
  shellspec_replace() {
    eval "shellspec_replace_rest=\${$1} shellspec_replace=''"
    shellspec_replace_pattern=$2
    shellspec_escape_meta_posh shellspec_replace_pattern
    set -- "$1" "$shellspec_replace_pattern" "$3"
    until case $shellspec_replace_rest in (*$2*) false; esac; do
      shellspec_replace=${shellspec_replace}${shellspec_replace_rest%%$2*}$3
      shellspec_replace_rest=${shellspec_replace_rest#*$2}
    done
    eval "$1=\$shellspec_replace\$shellspec_replace_rest"
  }
fi

shellspec_ends_with_backslash() {
  case $1 in (*\\) true ;; (*) false ;; esac
}

# workaround for posh 0.3.14, 0.5.4
if ! shellspec_ends_with_backslash "\\"; then
  shellspec_ends_with_backslash() {
    case $1 in (*\\\\) true ;; (*) false ;; esac
  }
fi

# shellspec_match() deprecated
shellspec_match() {
  [ "${2:-}" ] && eval "case \${1:-} in ($2) true ;; (*) false ;; esac &&:"
}

shellspec_escape_syntax() {
  shellspec_replace "$1" \\ \\\\
  shellspec_replace "$1" \" \\\"
  shellspec_replace "$1" \# \\\#
  shellspec_replace "$1" \$ \\\$
  shellspec_replace "$1" \& \\\&
  shellspec_replace "$1" \' \\\'
  shellspec_replace "$1" \( \\\(
  shellspec_replace "$1" \) \\\)
  shellspec_replace "$1" \; \\\;
  shellspec_replace "$1" \< \\\<
  shellspec_replace "$1" \> \\\>
  shellspec_replace "$1" \` \\\`
  shellspec_replace "$1" \~ \\\~
  shellspec_replace "$1" "=" "\\="
  shellspec_replace "$1" "^" "\\^"
  shellspec_replace "$1" " " '" "'
  shellspec_replace "$1" "$SHELLSPEC_TAB" "\\$SHELLSPEC_TAB"
  shellspec_replace "$1" "$SHELLSPEC_LF" '"$SHELLSPEC_LF"'
  shellspec_replace "$1" "$SHELLSPEC_CR" '"$SHELLSPEC_CR"'
  shellspec_replace "$1" "$SHELLSPEC_VT" '"$SHELLSPEC_VT"'
}

shellspec_match_pattern() {
  [ "${2:-}" ] || return 1
  shellspec_match_pattern=$2
  shellspec_escape_syntax shellspec_match_pattern
  set -- "$1" "$shellspec_match_pattern"
  eval "case \$1 in ($2) true ;; (*) false ;; esac &&:" 2>/dev/null
}

shellspec_escape_pattern() {
  shellspec_escape_syntax "$1"
  shellspec_replace "$1" "|" "\\|"
  shellspec_replace "$1" "[" "\\["
  shellspec_replace "$1" "]" "\\]"
  shellspec_replace "$1" "*" "\\*"
  shellspec_replace "$1" "?" "\\?"
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

shellspec_which() {
  set -- "$1" "${PATH%:}:"
  while [ "${2%:}" ]; do
    [ -x "${2%%:*}/$1" ] && echo "${2%%:*}/$1" && return 0
    set -- "$1" "${2#*:}"
  done
  return 1
}

# $1: variable name (e.g. VALUES [spec/foo/1.sh:@1:@2-1:@2-2:@3])
# $2: delimiter
# $3: values (e.g. @1:@2-2)
shellspec_difference_values() {
  SHELLSPEC_EVAL="
    set -- \"\$1\" \"\$2\" \"\${3:-}\$2\" \"\$2\$$1\$2\"; \
    while [ \"\$3\" ]; do \
      while :; do \
        $1=\$2 && $1=\${3%%\"\$$1\"*} && $1=\"\$2\$$1\$2\"; \
        case \$4 in \
          *\$$1*) \
            $1=\${4%%\"\$$1\"*}\$2\${4#*\"\$$1\"}; \
            set -- \"\$1\" \"\$2\" \"\$3\" \"\$$1\" ;; \
          *) break ;; \
        esac; \
      done; \
      $1=\$2 && $1=\${3#*\"\$$1\"}; \
      set -- \"\$1\" \"\$2\" \"\$$1\" \"\$4\"; \
    done; \
    $1=\$4 && $1=\${$1%\"\$2\"} && $1=\${$1#\"\$2\"}; \
  "
  eval "$SHELLSPEC_EVAL"
}

# $1: variable name (e.g. VALUES [spec/foo/1.sh:@1:@2-1:@2-2:@3])
# $2: delimiter
# $3: values (e.g. @1:@2-2)
shellspec_union_values() {
  SHELLSPEC_EVAL="
    set -- \"\$1\" \"\$2\" \"\${$1}\${3:+\$2}\${3:-}\" \"\$2\"; \
    $1=\$2 && set -- \"\$1\" \"\$2\" \"\$3\${3:+\"\$$1\"}\" \"\$4\"; \
    while [ \"\$3\" ]; do \
      $1=\${3%%\"\$$1\"*} && set -- \"\$@\" \"\$$1\" && $1=\$2; \
      case \$4 in \
        *\$2\$5\$2*) ;; \
        *) set -- \"\$1\" \"\$2\" \"\$3\" \"\$4\$5\$2\" ;; \
      esac; \
      $1=\${3#*\"\$$1\"} && set -- \"\$1\" \"\$2\" \"\$$1\" \"\$4\" && $1=\$2; \
    done; \
    $1=\$4; $1=\${$1%\"\$2\"}; $1=\${$1#\"\$2\"}; $1=\${$1#\"\$2\"}; \
  "
  eval "$SHELLSPEC_EVAL"
}

shellspec_is_empty_file() {
  [ "${1:-}" ] && [ -f "${1:-}" ] && [ ! -s "${1:-}" ]
}
