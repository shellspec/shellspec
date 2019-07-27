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

# Workaround for busybox-1.1.3, ksh 93q, ksh 93r
if [ "$SHELLSPEC_DEFECT_REDEFINE" ]; then
  shellspec_unbuiltin() {
    eval "alias $1='shellspec_unbuiltin_$1'"
    eval "shellspec_unbuiltin_$1() { \\$1 \"\$@\"; }"
  }
  shellspec_unbuiltin "test"
else
  shellspec_unbuiltin() { :; }
fi

if ! (unset A ||:; unset A); then
  case $SHELLSPEC_SHELL_TYPE in
    bash|zsh)
      shellspec_fix_unset() {
        eval 'unset() { builtin unset "$@" ||:; }'
      }
      ;;
    *)
      shellspec_unset() {
        while [ $# -gt 0 ]; do eval "\unset $1 ||:" && shift; done
      }
      shellspec_fix_unset() {
        eval 'alias unset=shellspec_unset'
      }
  esac
else
  shellspec_fix_unset() { :; }
fi

if [ "${SHELLSPEC_DEFECT_READONLY:-}" ]; then
  alias readonly=''
fi

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

if [ "$SHELLSPEC_PROFILER" ]; then
  shellspec_profile_start() { shellspec_profile_wait; }
  shellspec_profile_end() { shellspec_profile_wait; }
  shellspec_profile_wait() {
    echo = > "$SHELLSPEC_PROFILER_SIGNAL"
    while [ -s "$SHELLSPEC_PROFILER_SIGNAL" ]; do :; done
  }
else
  shellspec_profile_start() { :; }
  shellspec_profile_end() { :; }
fi

case $- in
  *e*) SHELLSPEC_ERREXIT=1 ;;
  *) SHELLSPEC_ERREXIT=''; set -e ;;
esac
