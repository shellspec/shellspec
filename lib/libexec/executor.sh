#shellcheck shell=sh

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"
use find_files puts putsn sequence

# shellcheck source=lib/libexec/parser.sh
. "${SHELLSPEC_LIB:-./lib}/libexec/parser.sh"

translator() {
  translator="$SHELLSPEC_LIBEXEC/shellspec-translator.sh"
  shell "$translator" "$@"
}

shell() {
  eval "$SHELLSPEC_SHELL" ${1+'"$@"'}
}
