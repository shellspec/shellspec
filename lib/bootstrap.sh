#shellcheck shell=sh disable=SC2016

# shellcheck source=lib/general.sh
. "$SHELLSPEC_LIB/general.sh"

# Workaround for ksh (Version AJM 93u+ 2012-08-01)
# ksh can not redefine existing function in some cases inside of sub shell.
#
# ```ksh
# foo() { echo foo1; }
# ( foo() { echo foo2; }; foo) # => output 'foo1', not 'foo2'
# ````
#
# If you want to redefine function on ksh, use shellspec_redefinable in spec helper
#
if [ "$SHELLSPEC_SHELL_TYPE" = ksh ]; then
  # $1: function name
  shellspec_redefinable() { eval "alias $1='shellspec_redefinable_ $1'"; }
  shellspec_redefinable_() { "$@"; }
else
  shellspec_redefinable() { :; }
fi

shellspec_terminate() {
  [ "${SHELLSPEC_SPECFILE:-}" ] || return 0
  echo "${SHELLSPEC_LF}${SHELLSPEC_CAN}"
  echo "${SHELLSPEC_LF}Running spec '$SHELLSPEC_SPECFILE' aborted." >&2
}
trap 'shellspec_terminate' EXIT

shellspec_load_requires() {
  shellspec_reset_params '$1' ':'
  eval "$SHELLSPEC_RESET_PARAMS"
  while [ $# -gt 0 ]; do
    eval "shellspec_$1_configure() { :; }"
    shellspec_import "$1"
    shift
  done
}
shellspec_load_requires "$SHELLSPEC_REQUIRES"

shellspec_import "core"

shellspec_call_configure() {
  shellspec_reset_params '$1' ':'
  eval "$SHELLSPEC_RESET_PARAMS"
  while [ $# -gt 0 ]; do "shellspec_$1_configure"
    shift
  done
}
shellspec_call_configure "$SHELLSPEC_REQUIRES"
