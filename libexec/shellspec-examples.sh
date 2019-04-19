#!/bin/sh
#shellcheck disable=SC2004

set -eu

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"
load parser

count=0
specfile() {
  while read -r line || [ "$line" ]; do
    if is_example "${line%% *}"; then
      count=$(($count + 1))
    fi
  done < "$1"
}
find_specfiles specfile "$@"

if [ "${SHELLSPEC_EXAMPLES_LOG:-}" ]; then
  echo "$count" > "${SHELLSPEC_EXAMPLES_LOG}#"
  mv "${SHELLSPEC_EXAMPLES_LOG}#" "$SHELLSPEC_EXAMPLES_LOG"
fi

echo "$count"
