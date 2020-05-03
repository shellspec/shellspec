#shellcheck shell=sh

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"

executor() {
  count=0
  eval count_specfiles count ${1+'"$@"'}
  create_workdirs "$count"
  translator "$@" | $SHELLSPEC_SHELL
}
