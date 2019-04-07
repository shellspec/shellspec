#!/bin/sh

# shellcheck source=lib/general.sh
. "${SHELLSPEC_LIB:-./lib}/general.sh"
# shellcheck source=lib/libexec/examples.sh
. "${SHELLSPEC_LIB:-./lib}/libexec/examples.sh"
# shellcheck source=lib/libexec/parser.sh
. "${SHELLSPEC_LIB:-./lib}/libexec/parser.sh"

i=0
each_file() {
  is_specfile "$1" || return 0
  while read -r line; do
    is_example "${line%% *}" && i=$((i+1))
  done < "$1"
}
find_files each_file "$@"

if [ "$SHELLSPEC_EXAMPLES_LOG" ]; then
  echo "$i" > "${SHELLSPEC_EXAMPLES_LOG}#"
  mv "${SHELLSPEC_EXAMPLES_LOG}#" "$SHELLSPEC_EXAMPLES_LOG"
fi

echo "$i"
