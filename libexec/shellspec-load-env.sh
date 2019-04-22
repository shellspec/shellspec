#!/bin/sh

set -eu

# shellcheck disable=SC1090
. "$SHELLSPEC_ENV_FROM"

exec="$SHELLSPEC_LIBEXEC/shellspec-${SHELLSPEC_MODE}.sh"
eval exec "$SHELLSPEC_SHELL" "\"$exec\"" ${1+'"$@"'}
