#shellcheck shell=sh disable=SC2004

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"

mktempdir() {
  (umask 0077; mkdir "$1"; chmod 0700 "$1")
}

rmtempdir() {
  rm -rf "$1"
}
