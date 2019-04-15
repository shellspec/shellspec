#!/bin/sh
#shellcheck disable=SC2004

set -eu

if [ "$SHELLSPEC_JOBS" -gt 0 ]; then
  # shellcheck source=lib/libexec/parallel-executor.sh
  . "${SHELLSPEC_LIB:-./lib}/libexec/parallel-executor.sh"
else
  # shellcheck source=lib/libexec/serial-executor.sh
  . "${SHELLSPEC_LIB:-./lib}/libexec/serial-executor.sh"
fi
use trim
load parser

translator() {
  translator="$SHELLSPEC_LIBEXEC/shellspec-translator.sh"
  shell "$translator" "$@"
}

shell() {
  eval "$SHELLSPEC_SHELL" ${1+'"$@"'}
}

error_handler() {
  specfile='' lineno='' errors=''

  while IFS= read -r line; do
    case $line in
      ${SHELLSPEC_SYN}shellspec_marker:*)
        if [ "$errors" ]; then
          puts "$errors"
          errors=''
          display_unexpected_error "$specfile" "$lineno"
        fi

        line=${line#${SHELLSPEC_SYN}shellspec_marker:}
        specfile=${line% *} lineno=${line##* }
        ;;
      *) errors="$errors$line${SHELLSPEC_LF}" ;;
    esac
  done

  if [ "$errors" ]; then
    puts "$errors"
    display_unexpected_error "$specfile" "$lineno" "$errors"
  fi
}

display_unexpected_error() {
  case $2 in
    ---) set -- "$1" '' ;;
    BOF) set -- "$1" 1  ;;
    EOF) return 0 ;; # no error
  esac

  if [ "$2" ]; then
    range=$(detect_range "$2" < "$1")
    putsn "Unexpected output to the stderr at line $range in '$1'"
  else
    putsn "Unexpected error (syntax error?) occurred in '$1'"
  fi
}

detect_range() {
  lineno_begin=$1 lineno_end='' lineno=0
  while IFS= read -r line || [ "$line" ]; do
    trim line
    line=${line%% *}
    line=${line#x}
    lineno=$(($lineno + 1))
    [ "$lineno" -lt "$1" ] && continue
    if [ "$lineno" -eq "$1" ]; then
      is_block_statement "$line" && lineno_begin=$(($lineno + 1))
    else
      is_block_statement "$line" && lineno_end=$(($lineno - 1)) && break
    fi
  done
  echo "${lineno_begin}-${lineno_end:-$lineno}"
}

( ( ( ( executor "$@" 2>&1 >&4; echo $? >&5 ) 2>&1 \
  | error_handler >&3) 5>&1) \
  | (read -r xs; exit "$xs") \
) 4>&1
