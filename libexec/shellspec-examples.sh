#!/bin/sh

# shellcheck source=lib/libexec/examples.sh
. "${SHELLSPEC_LIB:-./lib}/libexec/examples.sh"

i=0
specfile() {
  while read -r line; do
    is_example "${line%% *}" && i=$((i+1))
  done < "$1"
}
find_specfiles specfile "$@"

if [ "$SHELLSPEC_EXAMPLES_LOG" ]; then
  echo "$i" > "${SHELLSPEC_EXAMPLES_LOG}#"
  mv "${SHELLSPEC_EXAMPLES_LOG}#" "$SHELLSPEC_EXAMPLES_LOG"
fi

echo "$i"
