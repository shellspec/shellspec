#!/bin/sh

set -eu

# gosh: https://github.com/mvdan/sh v3.0.2 fails
umask >/dev/null

# mrsh: https://github.com/emersion/mrsh WIP 657ea07 fails
( false ) 2>/dev/null && exit 1

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

if "${0%/*}/shellspec-shebang" 2>/dev/null; then
  echo "SHELLSPEC_SHEBANG_MULTIARG=1"
fi

if [ "${BASH_VERSION:-}" ]; then
  echo "SHELLSPEC_KCOV_COMPATIBLE_SHELL=1"
fi

# arithmetic expansion is also required
exit $((0))
