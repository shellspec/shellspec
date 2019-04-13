#shellcheck shell=sh disable=SC2016

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"
use putsn reset_params

task() { :; }

invoke() {
  while :; do
    case $SHELLSPEC_TASKS in (*"|$1|"*) ;; (*) break; esac
    reset_params '$1' ":"
    eval "$RESET_PARAMS"
    IFSORIG=$IFS && IFS=_ && task="$*" && IFS=$IFSORIG

    task_file=''
    eval "[ \"\${SHELLSPEC_TASK_$task:+x}\" ] &&:" || break
    eval "task_file=\$SHELLSPEC_TASK_$task"
    [ -e "$task_file" ] || break
    {
      putsn ". \"$SHELLSPEC_LIB/general.sh\""
      putsn ". \"$SHELLSPEC_LIB/libexec/task.sh\""
      while IFS= read -r line || [ "$line" ]; do
        putsn "$line"
      done < "$task_file"
      putsn "${task}_task"
    } | $SHELLSPEC_SHELL
    return 0
  done

  putsn "Not found task '$1'" >&2
  exit 1
}
