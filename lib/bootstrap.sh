#shellcheck shell=sh disable=SC2016

shellspec() { :; }

# shellcheck source=lib/general.sh
. "$SHELLSPEC_LIB/general.sh"

# Workaround for ksh #40 in contrib/bugs.sh
if [ "$SHELLSPEC_DEFECT_REDEFINE" ]; then
  shellspec_redefinable() { eval "alias $1='shellspec_redefinable_ $1'"; }
  shellspec_redefinable_() { "$@"; }
else
  shellspec_redefinable() { :; }
fi

# Workaround for busybox-1.1.3, ksh 88
if [ "$SHELLSPEC_DEFECT_BUILTIN" ]; then
  shellspec_unbuiltin() {
    set -- "$1" "shellspec_unbuiltin_$1"
    eval "alias $1='$2'; $2() { \\$1 \${1+\"\$@\"}; }"
  }
  shellspec_unbuiltin "test"
else
  shellspec_unbuiltin() { :; }
fi

if [ "${SHELLSPEC_DEFECT_READONLY:-}" ]; then
  alias readonly=''
fi

shellspec_load_requires() {
  shellspec_reset_params '$1' ':'
  eval "$SHELLSPEC_RESET_PARAMS"
  set -- "$@" ":" "$@"

  until [ "$1" = ":" ] && shift; do
    eval "shellspec_$1_configure() { :; }"
    shellspec_import "$1"
    shift
  done

  shellspec_import "core"

  while [ $# -gt 0 ]; do
    "shellspec_$1_configure"
    shift
  done
}
shellspec_load_requires "$SHELLSPEC_REQUIRES"

if [ "$SHELLSPEC_PROFILER" ] && [ "$SHELLSPEC_PROFILER_LIMIT" -gt 0 ]; then
  shellspec_profile_start() { shellspec_profile_wait; }
  shellspec_profile_end() { shellspec_profile_wait; }
else
  shellspec_profile_start() { :; }
  shellspec_profile_end() { :; }
fi
shellspec_profile_wait() {
  echo = > "$SHELLSPEC_PROFILER_SIGNAL"
  while [ -s "$SHELLSPEC_PROFILER_SIGNAL" ]; do :; done
}

#shellcheck disable=SC2034
case $- in
  *e*) SHELLSPEC_ERREXIT="-e" ;;
  *) SHELLSPEC_ERREXIT="+e"; set -e ;;
esac
