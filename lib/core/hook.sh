#shellcheck shell=sh disable=SC2004

SHELLSPEC_BEFORE_EACH_INDEX=0
SHELLSPEC_AFTER_EACH_INDEX=0

shellspec_before_each_hook() {
  while [ $# -gt 0 ]; do
    SHELLSPEC_BEFORE_EACH_INDEX=$(($SHELLSPEC_BEFORE_EACH_INDEX + 1))
    eval "SHELLSPEC_BEFORE_${SHELLSPEC_BEFORE_EACH_INDEX}=\$1"
    shift
  done
}

shellspec_after_each_hook() {
  while [ $# -gt 0 ]; do
    SHELLSPEC_AFTER_EACH_INDEX=$(($SHELLSPEC_AFTER_EACH_INDEX + 1))
    eval "SHELLSPEC_AFTER_${SHELLSPEC_AFTER_EACH_INDEX}=\$1"
    shift
  done
}

shellspec_call_before_each_hooks() {
  set -- "${1:-1}"
  [ "$1" -gt "$SHELLSPEC_BEFORE_EACH_INDEX" ] && return 0
  shellspec_call_hook "SHELLSPEC_BEFORE_$1"
  shellspec_call_before_each_hooks $(($1 + 1))
}

shellspec_call_after_each_hooks() {
  set -- "${1:-$SHELLSPEC_AFTER_EACH_INDEX}"
  [ "$1" -lt 1 ] && return 0
  shellspec_call_hook "SHELLSPEC_AFTER_$1"
  shellspec_call_after_each_hooks $(($1 - 1))
}

shellspec_call_hook() {
  eval "eval \${$1}"
}
