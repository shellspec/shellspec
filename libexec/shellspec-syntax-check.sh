#!/bin/sh

set -eu

# shellcheck source=lib/libexec/translator.sh
. "${SHELLSPEC_LIB:-./lib}/libexec/translator.sh"

exit_status='' syntax_error=''

trans() {
  case $1 in (constant)
    # shellcheck disable=SC2145
    "trans_$@"
  esac
}

trans_constant() {
  eval "$1=\\'$2\\'"
}

syntax_error() {
  putsn "Syntax error: $1 in $specfile line $lineno${2+:}${2:-}" >&2
  syntax_error=1
}

error_handler() {
  error=0
  while IFS= read -r line; do
    case $line in
      # Do not fail the warnings of ksh 2020.0.0
      *:\ warning:\ line\ *) warn "$line"; ;;
      *) error "$line"; error=1
    esac
  done
  return "$error"
}

syntax_check() {
  initialize
  translate < "$1"
  finalize
  [ "$syntax_error" ] && return 1
  $SHELLSPEC_SHELL -n "$1"
}

one_line_syntax_check() {
  set -- "$1" "shellspec_syntax_check() { : ${2}${LF} }"
  eval "$1=\$( eval \"\$2\" 2>&1 )" && return 0
  eval "$1=\"\${$1%%\$LF*}\""
  eval "$1=\"\${$1##*:}\""
  return 1
}

specfile() {
  specfile=$2
  putsn "$specfile"
  ( ( ( syntax_check "$specfile" >&3; echo $? >&5 ) 2>&1 \
    | ( error_handler >&2; echo $? >&5 ) ) 5>&1 \
    | (
      xs=0
      read -r xs1; read -r xs2
      [ "$xs1" -eq 0 ] || xs="$xs1"
      [ "$xs2" -eq 0 ] || xs="$xs2"
      set_exit_status "$xs"
    )
  ) 3>&1 || exit_status=$?
}
find_specfiles specfile "$@"

exit "${exit_status:-0}"
