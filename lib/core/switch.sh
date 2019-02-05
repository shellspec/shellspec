#shellcheck shell=sh

shellspec_on() {
  while [ $# -gt 0 ]; do eval "SHELLSPEC_SW_$1=1" && shift; done
}

shellspec_off() {
  while [ $# -gt 0 ]; do eval "SHELLSPEC_SW_$1=''" && shift; done
}

shellspec_toggle() {
  eval "shift; if \"\$@\"; then shellspec_on $1; else shellspec_off $1; fi"
}

shellspec_if() { eval "[ \"\${SHELLSPEC_SW_$1:-}\" ] &&:"; }
shellspec_unless() { ! shellspec_if "$1"; }
