#!/bin/sh

# Check shell script files

# This script is for development purposes.
# It provide as is, do not any support.
# It may change without notice.

# Example of use
#   contrib/check.sh

set -eu

sources() {
  echo shellspec
  find lib libexec -name '*.sh'
}

specs() {
  find spec -name '*.sh'
}

count() {
  printf '%6s: ' "$1"
  shift
  cat $@ | wc -lc | {
    read -r lines bytes
    printf '%3s files, %s lines, %s KiB\n' $# $lines $((bytes / 1024))
  }
}

echo '     #  lines bytes name'
wc -lc $(sources; specs) | nl | sed '$d'
echo

count source $(sources)
count spec $(specs)
count total $(sources; specs)
echo

echo "Checking scripts..."

if ! which shellcheck > /dev/null; then
  echo 'ERROR: shellcheck not found' >&2
  exit 1
fi

shellcheck $(sources; specs) || exit 1

echo "Done"
