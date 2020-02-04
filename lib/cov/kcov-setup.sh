#shellcheck shell=bash

{
  echo 'set -o functrace'
  trap -p DEBUG
} > "$SHELLSPEC_TMPBASE/kcov-debug-helper.sh" &&:

eval "shellspec_coverage_start() { $(trap -p DEBUG); }"

shellspec_coverage_stop() {
  trap - DEBUG
}
