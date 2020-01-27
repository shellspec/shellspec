#!/bin/sh

set -eu

info() {
  printf '\033[32m%s\033[0m\n' "$*"
}

if [ -e .env ]; then
  default_compose_project_name=shellspec
  while read -r line; do
    case $line in (COMPOSE_PROJECT_NAME=*)
      default_compose_project_name=''
    esac
  done < .env
  if [ "$default_compose_project_name" ]; then
    : "${COMPOSE_PROJECT_NAME:=$default_compose_project_name}"
    export COMPOSE_PROJECT_NAME
  fi
fi

target=${3:-}

export DOCKERFILE_BASE AUTHORS
DOCKERFILE_BASE="$(dirname "$1")/"
AUTHORS="$(git config user.name) <$(git config user.email)>"

# Emulate Docker Hub environment variables
export DOCKERFILE_PATH DOCKER_TAG IMAGE_NAME SOURCE_COMMIT
DOCKERFILE_PATH=$(basename "$1")
DOCKER_TAG=${3:-latest}
IMAGE_NAME=$2:$DOCKER_TAG
SOURCE_COMMIT=$(git rev-parse HEAD)

test="docker-compose${target:+.}$target.test.yml"
docker-compose -f ".dockerhub/$test" up --build --abort-on-container-exit

case $1 in
  /*) DOCKERFILE_PATH=$1 ;;
  *) DOCKERFILE_PATH=$PWD/$1 ;;
esac

cd .dockerhub
if [ "$target" ]; then
  hooks/build --target "$target"
else
  hooks/build
fi
size=$(docker inspect -f "{{.Size}}" "$IMAGE_NAME")
if [ "$size" -le $((1024 * 1024)) ]; then
  size="$(echo "scale=2; $size / 1024" | bc) KB"
else
  size="$(echo "scale=2; $size / 1024 / 1024" | bc) MB"
fi
labels=$(
  #shellcheck disable=SC2016
  format='{{range $k, $v := .Config.Labels}}{{printf "%s: %s\n" $k $v}}{{end}}'
  #shellcheck disable=SC2005
  echo "$(docker inspect -f "$format" "$IMAGE_NAME")"
)

info "============================================================"
info "Build succeeded: $IMAGE_NAME (size: $size)"
info "------------------------------------------------------------"
echo "$labels"
info "============================================================"
