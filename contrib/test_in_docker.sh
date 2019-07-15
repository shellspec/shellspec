#!/bin/sh

# Run tests in docker

# This script is for development purposes.
# It provide as is, do not any support.
# It may change without notice.

set -eu

if [ $# -eq 0 ]; then
cat <<'USAGE'
Usage: test_in_docker.sh [Dockerfile..] [-- COMMAND]

Run tests in docker

Examples
  contrib/test_in_docker.sh dockerfiles/*
  contrib/test_in_docker.sh dockerfiles/debian-9-*
  contrib/test_in_docker.sh dockerfiles/*bash* -- contrib/bugs.sh

To delete all shellspec images
  docker rmi $(docker images shellspec -q)
USAGE
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

iidfile=$(mktemp)
trap 'exit 1' INT
trap '[ -f "$iidfile" ] && rm "$iidfile"' EXIT

run() {
  dockerfile=$1 count=0

  while [ $# -gt 0 ]; do
    [ "$1" = "--" ] && shift && break
    shift
  done

  echo "======================================================================"
  echo "# $dockerfile: $@"
  count=$(($count + 1))
  tag="${dockerfile##*/}"
  tag="${tag#.}"
  image="shellspec:$tag"
  (
    cd contrib/mksock
    docker build -t shellspec:mksock .
  )
  docker build $options -t "$image" - < "$dockerfile"
  old_iid=$(docker images -q --no-trunc --filter "label=tag1=$image")
  docker build --iidfile "$iidfile" --label "tag1=$image" --build-arg "IMAGE=$image" . -f "dockerfiles/.shellspec"
  iid=$(cat "$iidfile")
  if [ "$old_iid" ] && [ "$iid" != "$old_iid" ]; then
    docker rmi "$old_iid" > /dev/null
  fi
  echo
  echo "# $dockerfile: $@"
  docker run -it --rm "$iid" "$@" &&:
  xs=$?
  echo "exit status: $xs"
  case $tag in
    *-fail) ;;
    *) [ $xs -eq 0 ] || exit 1
  esac
  echo
}

start=$(date) start_sec=$(date +%s)
main "$@"
end=$(date) end_sec=$(date +%s)
sec=$(($end_sec - $start_sec))

echo "$start"
echo "$end"
echo "Done. $count tests, $sec sec ($(( $sec / 60)) min)"
