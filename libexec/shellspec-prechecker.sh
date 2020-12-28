#!/bin/sh
# shellcheck disable=SC1090,SC2016,SC2034,SC2064

. "${SHELLSPEC_LIB:-./lib}/libexec/prechecker.sh"

warn_fd=2 status_file=""
while [ $# -gt 0 ]; do
  case ${1:-} in
    --warn-fd=*) warn_fd=${1#*\=} ;;
    --status-file=*) status_file=${1#*\=} ;;
    *) break ;;
  esac
  shift
done

: > "$status_file"

work="$status_file'" && status_file=''
while [ "$work" ]; do
  status_file="$status_file${work%%\'*}'\''"
  work=${work#*\'}
done
status_file=${status_file%????}

code='xs=${xs:-$?} mod=${1:-"<module>"};'
code="${code}if [ \"\${loaded:-}\" ]; then"
code="${code}  echo \"\$xs\" > '${status_file:-/dev/null}';"
code="${code}else"
code="${code}  \"\${SHELLSPEC_SLEEP:-sleep}\" 0;"
code="${code}  echo \"Skip precheck because an error (\$xs) occurred when loading the module '\$mod'\";"
code="${code}  echo \"Since ShellSpec 0.28.0, modules are loaded earlier, so it is no longer possible\";"
code="${code}  echo \"to call shellspec's internal functions from the top level of the module.\";"
code="${code}  echo \"If the module worked in an earlier ShellSpec version, move those codes to\";"
code="${code}  echo \"the function \${mod}_loaded or \${mod}_configure (recommended).\";"
code="${code}  echo \"The process will continue for compatibility, but will abort here in the future.\";"
# TODO abort here in the future
# code="${code}  echo \"\$xs\" > '${status_file:-/dev/null}';"
code="${code}fi >&$warn_fd"
trap "$code" EXIT
unset code warn_fd status_file work

{
  while [ $# -gt 0 ] && [ "${xs:-0}" -eq 0 ]; do
    set -- "${1##*/}" "$@"
    set -- "${1%%.*}" "$@"
    unset success xs loaded ||:
    eval "$1_precheck() { :; }"
    . "$3"
    unset success xs loaded ||:
    set +e
    { success=$( set -eu; eval "$1_precheck" >&7; xs=$?; [ "$xs" -eq 0 ] || exit "$xs"; echo 1 ); } 7>&1
    xs=$? loaded=1
    unset -f "$1_precheck"
    [ "$success" ] || break
    [ "$xs" -eq 0 ] || break
    shift 3
  done
  [ "$success" ] && trap - EXIT
  exit "$xs"
}
