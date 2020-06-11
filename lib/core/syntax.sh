#shellcheck shell=sh

SHELLSPEC_SYNTAXES=${SHELLSPEC_SYNTAXES:-:}
SHELLSPEC_COMPOUNDS="${SHELLSPEC_COMPOUNDS:-:}"

shellspec_syntax() {
  SHELLSPEC_SYNTAXES="${SHELLSPEC_SYNTAXES}$1:"
}

# allow "language chain" after word
shellspec_syntax_chain() {
  SHELLSPEC_SYNTAXES="${SHELLSPEC_SYNTAXES}$1:"
  shellspec_proxy "$1" "shellspec_syntax_dispatch ${1#shellspec_}"
}

# disallow "language chain" after word
shellspec_syntax_compound() {
  SHELLSPEC_SYNTAXES="${SHELLSPEC_SYNTAXES}$1:"
  shellspec_proxy "$1" "shellspec_syntax_dispatch ${1#shellspec_}"
  SHELLSPEC_COMPOUNDS="${SHELLSPEC_COMPOUNDS}$1:"
}

# just alias, do not dispatch.
shellspec_syntax_alias() {
  SHELLSPEC_SYNTAXES="${SHELLSPEC_SYNTAXES}$1:"
  shellspec_proxy "$1" "$2"
}

# $1:<syntax-type> $2:<name> $3-:<parameters>
shellspec_syntax_dispatch() {
  if [ "$1" = "subject" ]; then
    case $2 in (*"()")
      eval "shift 2; set -- $1 function \"${2%??}\" ${3+\"\$@\"}"
    esac
  fi

  case $SHELLSPEC_COMPOUNDS in (*:shellspec_$1:*) ;; (*)
    SHELLSPEC_EVAL="
      shift; \
      while [ \$# -gt 0 ]; do \
        case \$1 in (the|a|an|as) shift;; (*) break; esac; \
      done; \
      case \$# in \
        0) set -- \"$1\" ;; \
        *) set -- \"$1\" \"\$@\" ;; \
      esac
    "
    eval "$SHELLSPEC_EVAL"
  esac

  case $SHELLSPEC_SYNTAXES in (*:shellspec_$1_${2:-}:*)
    SHELLSPEC_SYNTAX_NAME="shellspec_$1_$2"
    shift 2
    case $# in
      0) "$SHELLSPEC_SYNTAX_NAME" ;;
      *) "$SHELLSPEC_SYNTAX_NAME" "$@" ;;
    esac
    return $?
  esac
  shellspec_output SYNTAX_ERROR_DISPATCH_FAILED "$@"
  shellspec_on SYNTAX_ERROR
}

# $1:count $2-:<condition>
# $1:<param posision> $2:(is) $3:<type> $4:<value>
shellspec_syntax_param() {
  if [ "$1" = count ]; then
    shellspec_syntax_param_check "$@" && return 0
    shellspec_output SYNTAX_ERROR_WRONG_PARAMETER_COUNT "$1"
  elif shellspec_is_number "$1"; then
    shellspec_syntax_param_check "$1" "shellspec_$2_$3" "$4" && return 0
    shellspec_output SYNTAX_ERROR_PARAM_TYPE "$1" "$3"
  else
    shellspec_error "shellspec_syntax_param: wrong parameter '$1'"
  fi

  shellspec_on SYNTAX_ERROR
  return 1
}

shellspec_syntax_param_check() {
  shift
  "$@"
}

shellspec_syntax_failure_message() {
  case $1 in
    +) SHELLSPEC_EVAL="shellspec_matcher__failure_message() {" ;;
    -) SHELLSPEC_EVAL="shellspec_matcher__failure_message_when_negated() {" ;;
  esac
  shift
  while [ $# -gt 0 ]; do
    SHELLSPEC_EVAL="${SHELLSPEC_EVAL}${SHELLSPEC_LF}shellspec_putsn \"$1\""
    shift
  done
  eval "${SHELLSPEC_EVAL}${SHELLSPEC_LF}}"
}
