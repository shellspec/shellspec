#!/bin/sh

set -eu

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
