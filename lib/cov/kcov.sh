#shellcheck shell=bash disable=SC2016

shellspec_coverage_setup() {
  SHELLSPEC_ENV="$SHELLSPEC_LIB/cov/kcov/.$1env"
  [ -e "$SHELLSPEC_ENV" ] || return 0

  shellspec_coverage=0
  shellspec_coverage_start() {
    set -- 'shellspec_coverage=$((shellspec_coverage + 1))' \
      '[ "$shellspec_coverage" -eq 1 ] || return 0'
    while IFS= read -r line; do
      set -- "$@" "$line"
    done < "$SHELLSPEC_ENV" &&:
    printf '%s\n' "shellspec_coverage_start() {" "${@:-}" "}"
  }
  eval "$(shellspec_coverage_start)"

  shellspec_coverage_stop() {
    if [ "$shellspec_coverage" -gt 0 ]; then
      shellspec_coverage=$((shellspec_coverage - 1))
      [ "$shellspec_coverage" -eq 0 ] || return 0
    fi
    trap - DEBUG
  }

  shellspec_coverage_env() {
    while IFS= read -r line; do
      case $line in ("#ENV "*)
        set -- "$@" "${line#* }"
      esac
    done < "$SHELLSPEC_ENV" &&:
    printf '%s\n' "shellspec_coverage_env() {" "${@:-:}" "}"
  }
  eval "$(shellspec_coverage_env)"
}
