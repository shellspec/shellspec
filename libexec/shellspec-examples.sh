#!/bin/sh

i=0
while IFS= read -r filename; do
  while read -r line; do
    case ${line%% *} in
      Example | Specify | It) i=$((i+1))
    esac
  done < "$filename"
done <<HERE
$(find spec -name "*_spec.sh")
HERE

if [ "$SHELLSPEC_EXAMPLES_LOG" ]; then
  echo "$i" > "${SHELLSPEC_EXAMPLES_LOG}#"
  mv "${SHELLSPEC_EXAMPLES_LOG}#" "$SHELLSPEC_EXAMPLES_LOG"
else
  echo "$i"
fi
