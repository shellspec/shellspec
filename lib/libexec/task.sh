#shellcheck shell=sh disable=SC2016

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"
use replace_all

SHELLSPEC_TASKS=''

task() {
  name=$1 task=''
  replace_all task "$name" ":" "_"
  SHELLSPEC_TASKS="$SHELLSPEC_TASKS${SHELLSPEC_TASKS:+ }$name"
  eval "SHELLSPEC_TASK_$task=\$SHELLSPEC_TASK_SOURCE"
  eval "SHELLSPEC_TASK_DESC_$task=\$2"
}

enum_tasks() {
  set -- "$1" "$SHELLSPEC_TASKS "
  while [ "$2" ]; do
    set -- "$1" "${2#* }" "${2%% *}"
    replace_all task "$3" ":" "_"
    eval "$1 \"\$3\" \"\$SHELLSPEC_TASK_DESC_$task\""
  done
}

invoke() {
  case " $SHELLSPEC_TASKS " in (*\ $1\ *) ;; (*)
    abort "Not found task '$1'"
  esac
  task='' task_file=''
  replace_all task "$1" ":" "_"
  eval "task_file=\$SHELLSPEC_TASK_$task"
  {
    echo ". \"\$SHELLSPEC_LIB/general.sh\""
    echo ". \"\$SHELLSPEC_LIB/libexec.sh\""
    echo "use which"
    echo "task() { :; }"
    cat "$task_file"
    echo
    echo "${task}_task"
  } | ( IFS=' '; $SHELLSPEC_SHELL )
}
