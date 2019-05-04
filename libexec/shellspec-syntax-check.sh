#!/bin/sh

set -eu

# shellcheck source=lib/libexec/translator.sh
. "${SHELLSPEC_LIB:-./lib}/libexec/translator.sh"

exit_status='' syntax_error=''

trans() { :; }

syntax_error() {
  putsn "Syntax error: $1 in $specfile line $lineno${2+:}${2:-}" >&2
  syntax_error=1
}

error_handler() {
  while IFS= read -r line; do
    error "$line"
  done
}

syntax_check() {
  initialize
  translate < "$1"
  finalize
  [ "$syntax_error" ] && return 1
  $SHELLSPEC_SHELL -n "$1"
}

one_line_syntax_check() {
  eval "$1=\$(\$SHELLSPEC_SHELL -n -c \"\$2\" 2>&1)" && return 0
  eval "$1=\"\${$1%%\$LF*}\""
  eval "$1=\"\${$1##*:}\""
  return 1
}

specfile() {
  specfile=$1
  putsn "$specfile"
  ( ( ( ( syntax_check "$specfile"; echo $? >&3 ) 2>&1 \
    | error_handler >&2) 3>&1) \
    | (read -r xs; exit "$xs") \
  ) 4>&1 || exit_status=1
}
find_specfiles specfile "$@"

exit "${exit_status:-0}"
