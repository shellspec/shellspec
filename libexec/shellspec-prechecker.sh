#!/bin/sh
# shellcheck disable=SC1090,SC2016,SC2034,SC2064

set -e

# shellcheck source=lib/libexec/prechecker.sh
. "${SHELLSPEC_LIB:-./lib}/libexec/prechecker.sh"

warn_fd=2 status_file="" xs=''
while [ $# -gt 0 ]; do
  case ${1:-} in
    --warn-fd=*) warn_fd=${1#*\=} ;;
    --status-file=*) status_file=${1#*\=} ;;
    *) break ;;
  esac
  shift
done

[ -s "$status_file" ] && : > "$status_file"

if [ $# -gt 0 ]; then
  for i in "$@"; do
    i=${i##*/} && i=${i%%.*}
    set -- "$@" "$i" "$1" "$status_file" "$warn_fd"
    shift
  done
fi
unset i status_file warn_fd

shellspec_precheck_loading_error() {
  "${SHELLSPEC_SLEEP:-sleep}" 0
  echo "Skip precheck because an error ($2) occurred when loading the module '$1'"
  echo "Since ShellSpec 0.28.0, modules are loaded earlier, so it is no longer possible"
  echo "to call shellspec's internal functions from the top level of the module."
  echo "If the module worked in an earlier ShellSpec version, move those codes to"
  echo "the function ${1}_loaded or ${1}_configure (recommended)."
  echo "The process will continue for compatibility, but will abort here in the future."
  # TODO abort here in the future
  # [ "$3" ] && echo "$2" > "$3"
  # exec $SHELLSPEC_SHELL -c "exit $2"
  # shellcheck disable=SC2086
  exec $SHELLSPEC_SHELL -c 'exit 0'
}

until [ $# -eq 0 ] || [ "$xs" ]; do
  unset xs
  eval "$1_precheck() { :; }"
  trap "shellspec_precheck_loading_error \"\$1\" \$? \"\$3\" >&$4" EXIT
  set -e
  . "$2"
  trap - EXIT
  { shellspec_precheck_run xs "$1_precheck >&7"; } 7>&1
  unset -f "$1_precheck"
  shift 4
done

[ "$xs" ] && [ "$3" ] && echo "$xs" > "$3"
exit "${xs:-0}"
