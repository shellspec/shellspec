#!/bin/sh

set -eu

: "${SH:=sh}"

# Workaround for GitHub Actions (SIGPIPE)
# In GitHub Actions, SIGPIPE seems to be set to SIG_IGN and if the process exits
# before receiving all STDIN data, it will result in Broken PIPE or I/O will be output
head() {
  command head "$@"
  cat >/dev/null
}

shellspec() {
  set -- $SH shellspec --shell "$SH" "$@"
  echo '$' "$@" >&2
  "$@"
}

shellspec --banner --output progress --output documentation --output tap --output junit --output failures
shellspec --no-banner --skip-message quiet -j 3
shellspec --no-banner --skip-message quiet $(shellspec --list specfiles | head -n 5)
shellspec --no-banner --skip-message quiet $(shellspec --list examples:lineno | head -n 5)
shellspec --no-banner --skip-message quiet spec/general_spec.sh:40:60:80:100
shellspec --no-banner --skip-message quiet spec/libexec --profile
shellspec --syntax-check
shellspec --count
shellspec --task
shellspec --task hello:shellspec
