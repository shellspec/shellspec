#!/bin/sh

# Check shell script files

# This script is for development purposes.
# It provide as is, do not any support.
# It may change without notice.

# Example of use
#   contrib/check.sh

set -eu

[ "${1:-}" = "--pull" ] && PULL=1 || PULL=""

sources() {
  echo shellspec
  echo install.sh
  find lib libexec -name '*.sh'
}

helpers() {
  find helper -name '*.sh'
}

specs() {
  find spec -name '*.sh'
}

examples() {
  find examples -name '*.sh'
}

count() {
  printf '%7s: ' "$1"
  shift
  cat "$@" | wc -lc | {
    read -r lines bytes
    printf '%3s files, %5s lines, %3s KiB\n' $# "$lines" $((bytes / 1024))
  }
}

echo '     #   lines  bytes name'
wc -lc $(sources; helpers; specs; examples) | nl | sed '$d'
echo

count source $(sources)
count helper $(helpers)
count spec $(specs)
count example $(examples)
count total $(sources; helpers; specs; examples)
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

# Do not use volume because can not be used on VolFs(lxfs) of WSL.
shellcheck_version=$(cat .shellcheck-version)
set -- -t "$tag" --build-arg "VERSION=$shellcheck_version"
[ "$PULL" ] && set -- "$@" --pull
docker build "$@" -f dockerfiles/.shellcheck .
docker run -i --rm "$tag" shellcheck --version
docker run -i --rm "$tag" shellcheck -C $(sources; helpers; specs; examples)

[ "$package_json_status" -ne 0 ] && exit "$package_json_status"

echo "ok"
