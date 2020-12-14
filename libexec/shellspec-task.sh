#!/bin/sh

set -eu

# shellcheck source=lib/libexec/task.sh
. "${SHELLSPEC_LIB:-./lib}/libexec/task.sh"
use find_files

show_task() {
  "$SHELLSPEC_PRINTF" '%-40s # %s\n' "$1" "$2"
}

run_tasks() {
  while [ $# -gt 0 ]; do
    invoke "$1"
    shift
  done
}

each_file() {
  case $1 in (*_task.sh)
    eval "SHELLSPEC_TASK_SOURCE=\$1"
    # shellcheck disable=SC1090
    . "$1"
  esac
}
find_files each_file "$SHELLSPEC_HELPERDIR/support"

if [ $# -eq 0 ]; then
  enum_tasks show_task
else
  run_tasks "$@"
fi
