#!/bin/sh
#shellcheck disable=SC2004

set -eu

# shellcheck source=lib/libexec/executor.sh
. "${SHELLSPEC_LIB:-./lib}/libexec/executor.sh"

if [ "$SHELLSPEC_KCOV" -gt 0 ]; then
  # shellcheck source=lib/libexec/kcov-executor.sh
  . "${SHELLSPEC_LIB:-./lib}/libexec/kcov-executor.sh"
elif [ "$SHELLSPEC_WORKERS" -gt 0 ]; then
  # shellcheck source=lib/libexec/parallel-executor.sh
  . "${SHELLSPEC_LIB:-./lib}/libexec/parallel-executor.sh"
else
  # shellcheck source=lib/libexec/serial-executor.sh
  . "${SHELLSPEC_LIB:-./lib}/libexec/serial-executor.sh"
fi
use constants trim
load grammar

translator() {
  translator="$SHELLSPEC_LIBEXEC/shellspec-translate.sh"
  eval "$SHELLSPEC_SHELL" "\"$translator\"" ${1+'"$@"'}
}

error_handler() {
  specfile='' lineno='' errors='' error_handler_status=0

  while IFS= read -r line; do
    case $line in
      ${SYN}shellspec_marker:*)
        if [ "$errors" ]; then
          detect_unexpected_error "$specfile" "$lineno" "$errors"
          errors=''
        fi
        line=${line#${SYN}shellspec_marker:}
        specfile=${line% *} lineno=${line##* }
        ;;
      Syntax\ error:*) putsn "${LF}${line}"; error_handler_status=1 ;;
      # Workaround for posh 0.6.13 when executed as a background process
      *internal\ error:\ j_async:\ bad\ nzombie*) ;;
      # Workaround for loksh <= 6.7.2 when executed as a background process
      *internal\ error:\ j_set_async:\ bad\ nzombie*) ;;
      # Workaround for ksh with coverage
      *version*sh*AT\&T\ Research*) ;;
      *) errors="${errors}${line}${LF}" error_handler_status=1
    esac
  done

  if [ "$error_handler_status" -ne 0 ]; then
    detect_unexpected_error "$specfile" "$lineno" "$errors"
  fi
  return $error_handler_status
}

detect_unexpected_error() {
  puts "$3"

  case $2 in
    ---) set -- "$1" '' ;;
    BOF) set -- "$1" 1  "$3" ;;
    EOF) return 0 ;; # no error
  esac

  if [ "$2" ]; then
    range=$(detect_range "$2" < "$1")
    if [ "$3" ]; then
      putsn "${LF}Unexpected output to stderr occurred at line $range in '$1'"
    else
      putsn "${LF}Unexpected exit at line $range in '$1'"
    fi
  else
    [ "$1" ] && set -- " occurred in '$1'"
    putsn "${LF}Unexpected error occurred (syntax error?)$1"
  fi
  nap
}

is_separetor_statement() {
  is_begin_block "$1" || is_end_block "$1" || is_oneline_example "$1"
}

detect_range() {
  lineno_begin=$1 lineno_end='' lineno=0
  while IFS= read -r line || [ "$line" ]; do
    trim line "$line"
    line=${line%% *} lineno=$(($lineno + 1))
    [ "$lineno" -lt "$1" ] && continue
    if is_separetor_statement "$line" ; then
      [ "$lineno" -ne "$1" ] && lineno_end=$(($lineno - 1)) && break
      lineno_begin=$lineno
    fi
  done
  echo "${lineno_begin}-${lineno_end:-$lineno}"
}

( ( ( ( set +e; executor "$@" 2>&1 >&4; echo $? >&5 ) 2>&1 \
  | error_handler >&3; echo $? >&5) 5>&1) \
  | (
      read -r xs1 && [ "$xs1" -ne 0 ] && exit "$xs1"
      read -r xs2 && [ "$xs2" -ne 0 ] && exit "$xs2"
      exit 0
    )
) 4>&1
