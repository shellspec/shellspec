#!/bin/sh

set -eu

# shellcheck source=lib/libexec/executer.sh
. "${SHELLSPEC_LIB:-./lib}/libexec/executer.sh"

translator() {
  translator="$SHELLSPEC_LIBEXEC/shellspec-translator.sh"
  shell "$translator" "$@"
}

shell() {
  # shellcheck disable=SC2086
  eval "command $SHELLSPEC_TIME $SHELLSPEC_SHELL ${1+\"\$@\"}"
}

{ { translator "$@" 2>&1 >&3; } | trans_log "$SHELLSPEC_TRANS_LOG" >&2; } 3>&1 \
  | \
{ { shell 2>&1 >&3; } | executer_log "$SHELLSPEC_TIME_LOG" >&2; } 3>&1
