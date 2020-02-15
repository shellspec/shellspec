#!/bin/sh

set -eu

if ! (exit $((0))) 2>/dev/null; then
  echo "SHELLSPEC_DEFECT_ARITHMETIC=1"
fi

# shellcheck disable=SC2123
if [ ! "$(PATH=; (kill -l) 2>/dev/null)" ]; then
  echo "SHELLSPEC_DEFECT_SIGNALS=1"
fi

if ! (false() { :; }; false) 2>/dev/null; then
  echo "SHELLSPEC_DEFECT_REDEFINE=1"
fi

# shellcheck disable=SC2034,SC2234
if ( [ "$( ( readonly value=123 ) 2>&1 )" ] ) 2>/dev/null; then
  echo "SHELLSPEC_DEFECT_READONLY=1"
fi

# shellcheck disable=SC2154
if (set -u; unset v ||:; : "$v") 2>/dev/null; then
  echo "SHELLSPEC_DEFECT_SHELL_FLAG=1"
fi
