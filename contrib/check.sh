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

samples() {
  find sample -name '*.sh'
}

count() {
  printf '%6s: ' "$1"
  shift
  cat $@ | wc -lc | {
    read -r lines bytes
    printf '%3s files, %5s lines, %3s KiB\n' $# $lines $((bytes / 1024))
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

echo "Checking package.json..."

contrib/make_package_json.sh | diff -u package.json - &&:
package_json_status=$?
[ "$package_json_status" -eq 0 ] && echo "ok"
echo

if ! docker --version >/dev/null 2>&1; then
  echo "You need docker to run shellcheck" >&2
  exit 1
fi

echo "Checking scripts by shellcheck..."

tag="shellspec:shellcheck"

trap 'exit 1' INT
trap 'docker rmi "$tag" >/dev/null 2>&1' EXIT

# Volume can not be used on VolFs of WSL.
shellcheck_version=$(cat .shellcheck-version)
docker build -t "$tag" --build-arg "VERSION=$shellcheck_version" . -f dockerfiles/.shellcheck > /dev/null
docker run -i --rm "$tag" --version
docker run -i --rm "$tag" -C $(sources; specs; samples)

[ "$package_json_status" -ne 0 ] && exit "$package_json_status"

echo "ok"
