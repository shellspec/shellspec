#shellcheck shell=sh

# shellcheck source=lib/general.sh
. "${SHELLSPEC_LIB:-./lib}/general.sh"

use() {
  while [ $# -gt 0 ]; do
    case $1 in
      unixtime) shellspec_import posix ;;
    esac
    case $1 in
      constants) shellspec_constants ;;
      reset_params)
        reset_params() {
          shellspec_reset_params "$@"
          eval 'RESET_PARAMS=$SHELLSPEC_RESET_PARAMS'
        }
        ;;
      *) shellspec_proxy "$1" "shellspec_$1" ;;
    esac
    shift
  done
}
