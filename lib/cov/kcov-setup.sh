#shellcheck shell=bash

{
  echo 'set -o functrace'
  trap=$(trap -p DEBUG)
  printf '%s\n' "${trap//"{BASH_SOURCE}"/"{BASH_SOURCE:-}"}"
} > "$SHELLSPEC_TMPBASE/kcov-debug-helper.sh" &&:

eval "shellspec_coverage_start() { $(trap -p DEBUG); }"

shellspec_coverage_stop() {
  trap - DEBUG
}
