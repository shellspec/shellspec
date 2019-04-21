#!/bin/sh

set -eu

$SHELLSPEC_SHELL "$SHELLSPEC_LIBEXEC/shellspec-count.sh" --list-examples "$@"
