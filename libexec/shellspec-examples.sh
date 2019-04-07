#!/bin/sh

# shellcheck source=lib/libexec/parser.sh
. "${SHELLSPEC_LIB:-./lib}/libexec/parser.sh"

i=0
while IFS= read -r filename; do
  while read -r line; do
    is_example "${line%% *}" && i=$((i+1))
  done < "$filename"
done <<HERE
$(find spec -name "*_spec.sh")
HERE

if [ "$SHELLSPEC_EXAMPLES_LOG" ]; then
  echo "$i" > "${SHELLSPEC_EXAMPLES_LOG}#"
  mv "${SHELLSPEC_EXAMPLES_LOG}#" "$SHELLSPEC_EXAMPLES_LOG"
fi

echo "$i"
