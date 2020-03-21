#!/bin/sh

set -eu

: "${SH:=sh}"

shellspec() {
  set -- $SH shellspec --shell "$SH" "$@"
  echo '$' "$@" >&2
  "$@"
}

shellspec --banner
shellspec --no-banner --skip-message quiet -j 3
shellspec --no-banner --skip-message quiet $(shellspec --list specfiles | head -n 5)
shellspec --no-banner --skip-message quiet $(shellspec --list examples:lineno | head -n 5)
shellspec --no-banner --skip-message quiet spec/general_spec.sh:40:60:80:100
shellspec --no-banner --skip-message quiet --profile
shellspec --syntax-check
shellspec --count
shellspec --task
shellspec --task hello:shellspec
