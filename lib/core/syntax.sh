#shellcheck shell=sh

SHELLSPEC_SYNTAXES="|" SHELLSPEC_COMPOUNDS="|"

shellspec_syntax() {
  SHELLSPEC_SYNTAXES="${SHELLSPEC_SYNTAXES}$1|"
}

# allow "language chain" after word
shellspec_syntax_chain() {
  SHELLSPEC_SYNTAXES="${SHELLSPEC_SYNTAXES}$1|"
  shellspec_proxy "$1" "shellspec_syntax_dispatch ${1#shellspec_}"
}

# disallow "language chain" after word
shellspec_syntax_compound() {
  SHELLSPEC_SYNTAXES="${SHELLSPEC_SYNTAXES}$1|"
  shellspec_proxy "$1" "shellspec_syntax_dispatch ${1#shellspec_}"
  SHELLSPEC_COMPOUNDS="${SHELLSPEC_COMPOUNDS}$1|"
}

# just alias, do not dispatch.
shellspec_syntax_alias() {
  SHELLSPEC_SYNTAXES="${SHELLSPEC_SYNTAXES}$1|"
  shellspec_proxy "$1" "$2"
}

# $1:<syntax-type> $2:<name> $3-:<parameters>
shellspec_syntax_dispatch() {
  if ! shellspec_includes "$SHELLSPEC_COMPOUNDS" "|shellspec_$1|"; then
    eval "
      shift
      while [ \$# -gt 0 ]; do
        case \$1 in (the|a|an|as) shift;; (*) break; esac
      done
      case \$# in
        0) set -- \"$1\" ;;
        *) set -- \"$1\" \"\$@\" ;;
      esac
    "
  fi

  if shellspec_includes "$SHELLSPEC_SYNTAXES" "|shellspec_$1_${2:-}|"; then
    SHELLSPEC_SYNTAX_NAME="shellspec_$1_$2" && shift 2
    eval "$SHELLSPEC_SYNTAX_NAME ${1+\"\$@\"}"
    return $?
  fi
  shellspec_output SYNTAX_ERROR_DISPATCH_FAILED "$@"
  shellspec_on SYNTAX_ERROR
}


# $1:count $2-:<condition>
# $1:<param posision> $2:(is) $3:<type> $4:<value>
shellspec_syntax_param() {
  if [ "$1" = count ]; then
    shellspec_syntax_param_check "$@" && return 0
    shellspec_output SYNTAX_ERROR_WRONG_PARAMETER_COUNT "$1"
  elif shellspec_is number "$1"; then
    shellspec_syntax_param_check "$1" "shellspec_$2" "$3" "$4" && return 0
    shellspec_output SYNTAX_ERROR_PARAM_TYPE "$1" "$3"
  else
    shellspec_error "shellspec_syntax_param: wrong parameter '$1'"
  fi

  shellspec_on SYNTAX_ERROR
  return 1
}

shellspec_syntax_param_check() { shift; "$@"; }