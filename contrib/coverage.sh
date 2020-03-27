#!/bin/sh

# Generate coverage

# This script is for development purposes.
# It provide as is, do not any support.
# It may change without notice.

set -eu

image="shellspec:coverage"

docker build -t "$image" -f "dockerfiles/.coverage" "$@" .
command="./shellspec --task fixture:stat:prepare; ./shellspec --kcov"
cid=$(docker create -it "$image" sh -c "$command")
docker start -ai "$cid"
rm -rf coverage
docker cp "$cid:/root/coverage" "coverage"
