#!/bin/sh
#shellcheck disable=SC2004

# Part of 22.sourced_script_spec.sh

count_lines() {
  i=0
  while read -r line || [ "$line" ]; do
    i=$(($i + 1))
  done
  echo "$i"
}

# When included from shellspec, __SOURCED__ variable defined and script
# end here. The script path is assigned to the __SOURCED__ variable.
${__SOURCED__:+return}

if [ "${1:-}" ]; then
  count_lines < "$1"
else
  echo "Usage: count_lines FILENAME" >&2
fi
