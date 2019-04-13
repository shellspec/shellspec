#!/bin/sh

set -eu

if [ "$SHELLSPEC_JOBS" -gt 0 ]; then
  # shellcheck source=lib/libexec/parallel-executor.sh
  . "${SHELLSPEC_LIB:-./lib}/libexec/parallel-executor.sh"
else
  # shellcheck source=lib/libexec/serial-executor.sh
  . "${SHELLSPEC_LIB:-./lib}/libexec/serial-executor.sh"
fi

translator() {
  translator="$SHELLSPEC_LIBEXEC/shellspec-translator.sh"
  shell "$translator" "$@"
}

shell() {
  eval "$SHELLSPEC_SHELL" ${1+'"$@"'}
}

executor "$@" 2>&3
