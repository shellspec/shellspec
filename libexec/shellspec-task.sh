#!/bin/sh
#shellcheck disable=SC2016

set -eu

# shellcheck source=lib/general.sh
. "${SHELLSPEC_LIB:-./lib}/general.sh"
# shellcheck source=lib/libexec/task.sh
. "${SHELLSPEC_LIB:-./lib}/libexec/task.sh"

export SHELLSPEC_TASKS

SHELLSPEC_TASKS='|'

task() {
  name=$1 desc=$2
  reset_params '$1' ":"
  eval "$RESET_PARAMS"
  IFSORIG=$IFS && IFS=_ && task="$*" && IFS=$IFSORIG
  SHELLSPEC_TASKS="$SHELLSPEC_TASKS$name|"
  eval "export SHELLSPEC_TASK_$task=\$task_file"
  eval "SHELLSPEC_TASK_DESC_$task=\$desc"
}

list_tasks() {
  reset_params '$1' '|'
  eval "$RESET_PARAMS"
  while [ $# -gt 0 ]; do
    [ "$1" ] && show_task "$1"
    shift
  done
}

show_task() {
  name=$1
  reset_params '$1' ":"
  eval "$RESET_PARAMS"
  IFSORIG=$IFS && IFS=_ && task="$*" && IFS=$IFSORIG
  eval "desc=\$SHELLSPEC_TASK_DESC_$task"
  printf '%-40s # %s\n' "$name" "$desc"
}

run_tasks() {
  while [ $# -gt 0 ]; do
    invoke "$1"
    shift
  done
}

while IFS= read -r task_file; do
  # shellcheck disable=SC1090
  . "$task_file"
done <<TASKS
$(find_files "*_task.sh" "$SHELLSPEC_SPECDIR/support")
TASKS

if [ $# -eq 0 ]; then
  list_tasks "$SHELLSPEC_TASKS"
else
  run_tasks "$@"
fi
