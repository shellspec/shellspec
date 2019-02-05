#!/bin/sh

# Run tests in docker

# This script is for development purposes.
# It provide as is, do not any support.
# It may change without notice.

# Example of use
#   contrib/test_in_docker.sh contrib/dockerfiles/debian-9-stretch/*
#   contrib/test_in_docker.sh -q $(find ./contrib -name "*-bash*") -- bash contrib/bugs.sh
#
# Delete all shellspec images
#   docker rmi $(docker images shellspec -q)

if [ $# -eq 0 ]; then
cat <<USAGE
Usage: test.sh [Dockerfile..] [-- COMMAND]

Run tests in docker

Available Dockerfile:
USAGE
  printf '  %s\n' $(find dockerfiles -type f)
  exit 0
fi

LF=$(printf '\n_')
LF=${LF%?}
option=""
dockerfiles=
while [ $# -gt 0 ]; do
  [ "$1" = "--" ] && shift && break
  [ "$1" = "-q" ] && option="$option -q" && shift && continue
  dockerfiles="${dockerfiles}$1${LF}"
  shift
done

while IFS= read -r dockerfile; do
  [ "$dockerfile" ] || continue
  echo "======================================================================"
  echo "$dockerfile: $@"
  echo "======================================================================"
  tag="${dockerfile##*/}"
  docker build $option -t "shellspec:$tag" ./ -f "$dockerfile"
  echo "======================================================================"
  echo
  case $# in
    0) docker run -t --rm "shellspec:$tag" ;;
    *) docker run -t --rm "shellspec:$tag" "$@" ;;
  esac
  echo
  echo
  echo
done <<HERE
$dockerfiles
HERE