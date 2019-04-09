#!/bin/sh

set -eu

# shellcheck source=lib/libexec/executer.sh
. "${SHELLSPEC_LIB:-./lib}/libexec/executer.sh"

translator() {
  translator="$SHELLSPEC_LIBEXEC/shellspec-translator.sh"
  # shellcheck disable=SC2086
  eval "$SHELLSPEC_SHELL \"\$translator\" \"\$@\""
}

shell() {
  # shellcheck disable=SC2086
  eval "command $SHELLSPEC_TIME $SHELLSPEC_SHELL"
}

translator "$@" \
  | { { shell 2>&1 >&3; } | executer_log "$SHELLSPEC_TIME_LOG" >&2; } 3>&1
