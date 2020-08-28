#shellcheck shell=bash disable=SC2016

shellspec_coverage_setup() {
  SHELLSPEC_ENV_FILE="$SHELLSPEC_LIB/cov/kcov/.$1env"
  [ -e "$SHELLSPEC_ENV_FILE" ] || return 0

  shellspec_coverage=0
  shellspec_coverage_start() {
    echo 'shellspec_coverage_start() {'
    echo 'shellspec_coverage=$((shellspec_coverage + 1))'
    echo '[ "$shellspec_coverage" -eq 1 ] || return 0'
    while IFS= read -r line; do
      echo "$line"
    done
    echo '}'
  }
  eval "$(shellspec_coverage_start < "$SHELLSPEC_ENV_FILE")"

  shellspec_coverage_stop() {
    if [ "$shellspec_coverage" -gt 0 ]; then
      shellspec_coverage=$((shellspec_coverage - 1))
      [ "$shellspec_coverage" -eq 0 ] || return 0
    fi
    trap - DEBUG
  }

  shellspec_coverage_env() {
    echo 'shellspec_coverage_env() {'
    while IFS= read -r line; do
      case $line in ("#ENV "*)
        echo "${line#* }"
      esac
    done
    echo '}'
  }
  eval "$(shellspec_coverage_env < "$SHELLSPEC_ENV_FILE")"
}
