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
  contrib/test_in_docker.sh dockerfiles/*-o # ends with -o is supported os
  contrib/test_in_docker.sh dockerfiles/*bash* -- contrib/bugs.sh

To delete all shellspec images
  docker rmi $(docker images shellspec -q)
USAGE
  exit 0
fi

LF="
"

failures='' count=0 failures_count=0 total_count=0

main() {
  options="" pull='' shift_count=0
  for arg in "$@"; do
    shift_count=$((shift_count + 1))
    case $arg in
      --) break ;;
      -*)
        [ "$arg" = "--pull" ] && pull=1
        options="${options}${arg} "
        ;;
      *) total_count=$((total_count + 1))
    esac
  done

  cd contrib/helpers
  docker build ${pull:+--pull} -t shellspec:helpers . | grayout
  cd "$OLDPWD"

  for arg in "$@"; do
    shift "$shift_count"
    shift_count=0
    case $arg in
      --) break ;;
      -*) continue ;;
    esac
    run "$arg" "$@"
  done
}

finished() {
  if [ -f "$iidfile" ]; then
    rm "$iidfile" ||:
  fi

  if [ "$failures" ]; then
    echo >&2
    echo "Failures:" >&2
    echo "$failures" >&2
  fi
}

info() {
  printf '\033[1;35m%s\033[0m\n' "$*" >&2
}

grayout() {
  while IFS= read -r line; do
    printf '\033[1;30m%s\033[0m\n' "$line" >&2
  done
}

iidfile=$(mktemp -t shellspec.XXXXXXXX)
trap 'finished; exit 1' INT
trap 'finished' EXIT

run() {
  dockerfile=$1
  shift

  info "======================================================================"
  info "$dockerfile:" "$@"
  count=$((count + 1))
  os="${dockerfile##*/}"
  os="${os#.}"
  os="${os%-!}"
  image="shellspec:$os"
  old_image=$(docker images -q --no-trunc "$image")

  # shellcheck disable=SC2086
  docker build --iidfile "$iidfile" $options - < "$dockerfile" | grayout
  base_image=$(cat "$iidfile")

  info "Create image from base image: $base_image"
  docker build --iidfile "$iidfile" -t "$image" --build-arg "IMAGE=$base_image" . -f "dockerfiles/.shellspec" | grayout
  new_image=$(cat "$iidfile")

  if [ "$old_image" ] && [ "$old_image" != "$new_image" ]; then
    info "Delete old image $old_image"
    docker rmi "$old_image" >/dev/null ||:
  fi
  info
  info "Starting $dockerfile:" "$@"
  info
  docker run -it --rm "$image" "$@" &&:
  xs=$?
  info
  if [ "$xs" -ne 0 ]; then
    failures="${failures}- ${os} [$xs]${LF}"
    failures_count=$((failures_count + 1))
  fi
  summary
  info
}

summary() {
  [ "$xs" -eq 0 ] && color="\033[32m" || color="\033[31m"
  [ "$failures_count" -eq 0 ] && fcolor="\033[32m" || fcolor="\033[31m"
  set -- "$count" "$total_count" "$failures_count"
  printf "${color}##############################\n\033[m"
  printf "${color}# exit status: %3d           #\n\033[m" "$xs"
  printf "${color}# ${fcolor}%3d / %3d (failures: %3d)${color}  #\n\033[m" "$@"
  printf "${color}##############################\n\033[m"
  if [ "$failures" ]; then
    echo "$failures"
  fi
} >&2

start=$(date) start_sec=$(date +%s)
main "$@"
end=$(date) end_sec=$(date +%s)
sec=$((end_sec - start_sec))

echo "$start" >&2
echo "$end" >&2
echo "Done. $count tests, $sec sec ($((sec / 60)) min)" >&2

if [ "$failures" ]; then
  exit 1
fi
