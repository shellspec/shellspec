#!/bin/sh

set -eu

# shellcheck source=lib/libexec/executor.sh
. "${SHELLSPEC_LIB:-./lib}/libexec/executor.sh"

translator --metadata "$@" | shell
