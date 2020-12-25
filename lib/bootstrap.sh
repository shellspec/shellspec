#shellcheck shell=sh disable=SC2016

shellspec() { echo '#'; }

# Disable verbose_errexit by default for osh
# shellcheck disable=SC2039,SC3044
shopt -u verbose_errexit 2>/dev/null ||:

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

shellspec_load_requires() {
  set -- "$1${1:+ }" "" "$1${1:+ }"

  while [ "$1" ] && set -- "${1#* }" "${1%% *}" "$3"; do
    eval "shellspec_$2_configure() { :; }"
    eval "shellspec_$2_loaded() { :; }"
    shellspec_import "$2"
    "shellspec_$2_loaded"
  done

  shellspec_import "core"

  shift 2
  while [ "$1" ] && set -- "${1#* }" "${1%% *}"; do
    "shellspec_$2_configure"
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
  echo '=' > "$SHELLSPEC_PROFILER_SIGNAL"
  while [ -s "$SHELLSPEC_PROFILER_SIGNAL" ]; do :; done
}

#shellcheck disable=SC2034
case $- in
  *e*) SHELLSPEC_ERREXIT="-e" ;;
  *) SHELLSPEC_ERREXIT="+e"; set -e ;;
esac

shellspec_coverage_disabled() {
  shellspec_coverage_env() { :; }
  shellspec_coverage_start() { :; }
  shellspec_coverage_stop() { :; }
}
