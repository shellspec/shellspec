#!/bin/sh

set -eu

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

for dockerfile; do
  export DOCKERFILE_PATH=${dockerfile#.dockerhub/}

  for test in .dockerhub/*.test.yml; do
    docker-compose -f "$test" up --build --abort-on-container-exit
  done

  for tag in latest kcov; do
    (
      export DOCKER_TAG=$tag IMAGE_NAME=shellspec:$tag
      cd .dockerhub
      hooks/build
    )
  done
done
