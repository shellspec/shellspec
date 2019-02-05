#shellcheck shell=sh

shellspec_unixtime() {
  if [ "${1:-}" ]; then eval "$1=$(date +%s)"; else date +%s; fi
}
