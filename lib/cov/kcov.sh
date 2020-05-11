#shellcheck shell=bash disable=SC2016

if [ "${BASH_VERSION:-}" ]; then
  SHELLSPEC_ENV="$SHELLSPEC_LIB/cov/kcov-bash-debug-helper.sh"
  shellspec_coverage_env() {
    export BASH_ENV="$SHELLSPEC_ENV"
  }
elif [ "${ZSH_VERSION:-}" ]; then
  SHELLSPEC_ENV="$SHELLSPEC_LIB/cov/kcov-zsh-debug-helper.sh"
  shellspec_coverage_env() {
    export ZDOTDIR="$SHELLSPEC_LIB/cov"
  }
elif [ "${KSH_VERSION:-}" ]; then
  SHELLSPEC_ENV="$SHELLSPEC_LIB/cov/kcov-ksh-debug-helper.sh"
  shellspec_coverage_env() {
    export ENV="$SHELLSPEC_ENV"
    # shellcheck disable=SC2034
    SHELLSPEC_COVERAGE_SHELL_OPTIONS="-E"
  }
fi

shellspec_coverage=0
shellspec_coverage_start() {
  set -- 'shellspec_coverage=$((shellspec_coverage + 1))' \
    '[ "$shellspec_coverage" -eq 1 ] || return 0'
  while IFS= read -r line; do set -- "$@" "$line"; done < "$SHELLSPEC_ENV"
  printf '%s\n' "shellspec_coverage_start() {" "$@" "}"
}
eval "$(shellspec_coverage_start)"

shellspec_coverage_stop() {
  if [ "$shellspec_coverage" -gt 0 ]; then
    shellspec_coverage=$((shellspec_coverage - 1))
    [ "$shellspec_coverage" -eq 0 ] || return 0
  fi
  trap - DEBUG
}
shellspec_coverage_stop
