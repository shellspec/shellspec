#!/bin/sh

set -eu

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"

exit_status=0

error() {
  if [ "$SHELLSPEC_COLOR" ]; then
    printf '\33[2;31m%s\33[0m\n' "${*:-}" >&2
  else
    printf '%s\n' "${*:-}" >&2
  fi
}

error_handler() {
  while IFS= read -r line; do
    error "$line"
  done
}

specfile() {
  putsn "$1"
  ( ( ( ( $SHELLSPEC_SHELL -n "$1"; echo $? >&3 ) 2>&1 \
    | error_handler >&4) 3>&1) \
    | (read -r xs; exit "$xs") \
  ) 4>&1 || exit_status=$?
}
find_specfiles specfile "$@"

exit "$exit_status"
