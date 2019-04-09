#!/bin/sh

set -eu

translator() {
  translator="$SHELLSPEC_LIBEXEC/shellspec-translator.sh"
  # shellcheck disable=SC2086
  eval "$SHELLSPEC_SHELL \"$translator\" \"\$@\""
}

shell() {
  # shellcheck disable=SC2086
  eval "$SHELLSPEC_SHELL"
}

translator --metadata "$@" | shell
