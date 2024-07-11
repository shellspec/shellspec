#!/bin/sh

# Generate coverage

# This script is for development purposes.
# It provide as is, do not any support.
# It may change without notice.

set -eu
export BUILDKIT_PROGRESS=plain
image="shellspec:coverage"

docker build -t "$image" -f "dockerfiles/.coverage" "$@" .
cmd="./shellspec --task fixture:stat:prepare; ./shellspec -s bash --kcov"
cid=$(docker create -it "$image" sh -c "$cmd")
docker start -ai "$cid"
workdir=$(docker inspect --format='{{.Config.WorkingDir}}' "$cid")
rm -rf coverage
docker cp "$cid:$workdir/coverage" "coverage"
docker rm "$cid"
