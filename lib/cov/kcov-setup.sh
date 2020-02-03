#shellcheck shell=bash

{
  echo 'set -o functrace'
  trap -p DEBUG
} > "$SHELLSPEC_TMPBASE/kcov-debug-helper.sh" &&:
