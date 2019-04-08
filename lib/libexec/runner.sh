#shellcheck shell=sh

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"
use readfile trim puts putsn
# shellcheck source=lib/libexec/parser.sh
. "${SHELLSPEC_LIB:-./lib}/libexec/parser.sh"

mktempdir() {
  (umask 0077; mkdir "$1"; chmod 0700 "$1")
}

rmtempdir() {
  rm -rf "$1" >/dev/null 2>&1
}
