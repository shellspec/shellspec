#!/bin/sh

set -eu

if [ "${1:-}" = "-" ] && shift; then
  [ $# -gt 0 ] && exec "$@"
  type bash >/dev/null 2>&1 && exec /bin/bash -l
  exec /bin/sh -l
fi

if [ -e .shellspec-docker/pre-test ]; then
  .shellspec-docker/pre-test
fi

shellspec "$@"

if [ -e .shellspec-docker/post-test ]; then
  .shellspec-docker/post-test
fi
