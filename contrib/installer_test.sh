#!/bin/sh

# Environment for installer test

# This script is for development purposes.
# It provide as is, do not any support.
# It may change without notice.

set -eu

iid='' iidfile=$(mktemp) dockerfile="dockerfiles/.installer-test"

cleanup() {
  [ -f "$iidfile" ] && rm "$iidfile"
  [ "$iid" ] && docker rmi "$iid" > /dev/null
}
trap 'exit 1' INT
trap 'cleanup' EXIT

docker build --target=installer -t "shellspec:installer" - < "$dockerfile"
docker build --target=test --iidfile "$iidfile" . -f "$dockerfile"
iid=$(cat "$iidfile")
docker run -it --rm "$iid" "$@"
