#!/bin/sh

# Generate coverage

# This script is for development purposes.
# It provide as is, do not any support.
# It may change without notice.

set -eu

finished() {
  if [ -f "$iidfile" ]; then
    rm "$iidfile" ||:
  fi
  if [ -f "$cidfile" ]; then
    cid=$(cat "$cidfile")
    docker rm "$cid" >/dev/null
    rm "$cidfile" ||:
  fi
}

iidfile=$(mktemp -t shellspec.XXXXXXXX)
cidfile=$(mktemp -t shellspec.XXXXXXXX)
trap 'finished; exit 1' INT
trap 'finished' EXIT

image="shellspec:coverage"

(
  cd contrib/mksock
  docker build -t shellspec:mksock .
)

old_image=$(docker images -q --no-trunc "$image")

docker build --iidfile "$iidfile" - < "dockerfiles/.coverage"
base_image=$(cat "$iidfile")

docker build --iidfile "$iidfile" -t "$image" --build-arg "IMAGE=$base_image" . -f "dockerfiles/.shellspec"
new_image=$(cat "$iidfile")

if [ "$old_image" ] && [ "$old_image" != "$new_image" ]; then
  docker rmi "$old_image" >/dev/null ||:
fi
rm "$cidfile"
docker run --cidfile "$cidfile" -it "$image" shellspec --kcov
cid=$(cat "$cidfile")
rm -rf coverage
docker cp "$cid:/shellspec/coverage" "coverage"
