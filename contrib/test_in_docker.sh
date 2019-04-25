#!/bin/sh

# Run tests in docker

# This script is for development purposes.
# It provide as is, do not any support.
# It may change without notice.

# Example of use
#   contrib/test_in_docker.sh dockerfiles/debian-9-*
#   contrib/test_in_docker.sh $(find ./dockerfiles -name "*-bash*") -- contrib/bugs.sh
#
# Delete all shellspec images
#   docker rmi $(docker images shellspec -q)

set -eu

if [ $# -eq 0 ]; then
cat <<USAGE
Usage: test.sh [Dockerfile..] [-- COMMAND]

Run tests in docker

Available Dockerfile:
USAGE
  printf '  %s\n' $(find dockerfiles -type f)
  exit 0
fi

main() {
  options=""
  for arg in "$@"; do
    case $arg in
      --) break ;;
      -*) options="${options}${arg} " ;;
    esac
  done

  while [ $# -gt 0 ]; do
    case $1 in
      --) break ;;
      -*) ;;
      *) run "$@" ;;
    esac
    shift
  done
}

run() {
  dockerfile=$1

  while [ $# -gt 0 ]; do
    [ "$1" = "--" ] && shift && break
    shift
  done

  echo "======================================================================"
  echo "[$dockerfile: $@]"
  tag="${dockerfile##*/}"
  docker build $options -t "shellspec:$tag" ./ -f "$dockerfile"
  echo
  docker run -it --rm "shellspec:$tag" "$@" &&:
  xs=$?
  case $tag in
    *-fail)  [ $xs -eq 0 ] && exit 1 ;;
    *) [ $xs -eq 0 ] || exit 1
  esac
  echo
}

main "$@"

echo Done
