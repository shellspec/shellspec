#!/bin/sh
# shellcheck disable=SC2046

# Check shell script files

# This script is for development purposes.
# It provide as is, do not any support.
# It may change without notice.

# Example of use
#   contrib/check.sh

set -eu

image="koalaman/shellcheck"

shellcheck() {
  if ! docker --version >/dev/null 2>&1; then
    echo "You need docker to run shellcheck" >&2
    exit 1
  fi

  if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
    pwd() { wslpath -w -a .; }
  fi

  docker run -i -v "$(pwd):/src" -w /src "$image" "$@"
}

sources() {
  echo shellspec
  find lib libexec -name '*.sh'
}

specs() {
  find spec -name '*.sh'
}

samples() {
  find sample/spec -name '*.sh'
}

count() {
  printf '%6s: ' "$1"
  shift
  cat "$@" | wc -lc | {
    read -r lines bytes
    printf '%3s files, %5s lines, %3s KiB\n' $# "$lines" $((bytes / 1024))
  }
}

echo '     #   lines  bytes name'
wc -lc $(sources; specs; samples) | nl | sed '$d'
echo

count source $(sources)
count spec $(specs)
count sample $(samples)
count total $(sources; specs; samples)
echo

echo "Checking scripts by shellcheck..."
shellcheck -C $(sources; specs; samples)

echo "ok"
