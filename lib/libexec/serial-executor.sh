#shellcheck shell=sh

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"

executor() {
  translator "$@" | $SHELLSPEC_SHELL
}
