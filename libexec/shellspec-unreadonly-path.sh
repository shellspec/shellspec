#!/bin/sh -eu
# shellcheck disable=SC2039
typeset +x PATH
exec "$SHELLSPEC_ENV" PATH="$PATH" SHELLSPEC_PATH_IS_READONLY='' "$SHELLSPEC_SHELL" "$@"
