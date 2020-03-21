#!/bin/sh

# Environment for installer test

# This script is for development purposes.
# It provide as is, do not any support.
# It may change without notice.

set -eu

[ $# -eq 0 ] && set -- general

case ${1:-} in ( general | make | bpkg | basher | brew) ;; (*)
cat <<'USAGE'
Usage: installer_test.sh [ general | make | bpkg | basher | brew]
USAGE
  exit 0
esac

iid='' iidfile=$(mktemp -t shellspec.XXXXXXXX)
dockerfile="dockerfiles/.installer-test"

cleanup() {
  [ -f "$iidfile" ] && rm "$iidfile"
  [ "$iid" ] && docker rmi "$iid" > /dev/null
}
trap 'exit 1' INT
trap 'cleanup' EXIT

docker build --target="${1}_installer" -t "shellspec:${1}_installer" - < "$dockerfile"
sleep 5
docker build --target=test --build-arg "TYPE=$1" --iidfile "$iidfile" . -f "$dockerfile"
iid=$(cat "$iidfile")
shift
docker run -it --rm "$iid" "$@"
