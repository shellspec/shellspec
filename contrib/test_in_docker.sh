#!/bin/sh

# Run tests in docker

# This script is for development purposes.
# It provide as is, do not any support.
# It may change without notice.

# Example of use
#   contrib/test_in_docker.sh dockerfiles/debian-9-*
#   contrib/test_in_docker.sh $(find ./dockerfiles -name "*-bash*") -- bash contrib/bugs.sh
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
  echo "$dockerfile: $@"
  echo "======================================================================"
  tag="${dockerfile##*/}"
  docker build $option -t "shellspec:$tag" ./ -f "$dockerfile"
  echo "======================================================================"
  echo
  case $# in
    0) docker run -it --rm "shellspec:$tag" ;;
    *) docker run -it --rm "shellspec:$tag" "$@" ;;
  esac
  echo
}

main "$@"
