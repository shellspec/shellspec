#shellcheck shell=sh disable=SC2004

SHELLSPEC_BEFORE_INDEX=0
SHELLSPEC_AFTER_INDEX=0

shellspec_before_hook() {
  while [ $# -gt 0 ]; do
    SHELLSPEC_BEFORE_INDEX=$(($SHELLSPEC_BEFORE_INDEX + 1))
    shellspec_register_hook BEFORE $SHELLSPEC_BEFORE_INDEX "$1"
    shift
  done
}

shellspec_after_hook() {
  while [ $# -gt 0 ]; do
    SHELLSPEC_AFTER_INDEX=$(($SHELLSPEC_AFTER_INDEX + 1))
    shellspec_register_hook AFTER $SHELLSPEC_AFTER_INDEX "$1"
    shift
  done
}

shellspec_register_hook() {
  eval "SHELLSPEC_$1_$2=\$3:\${SHELLSPEC_AUX_LINENO:-}"
}

shellspec_call_before_hooks() {
  if [ $# -eq 0 ]; then
    shellspec_call_before_hooks 1
  else
    [ "$1" -gt "$SHELLSPEC_BEFORE_INDEX" ] && return 0
    shellspec_call_hook "SHELLSPEC_BEFORE_$1" || return $?
    shellspec_call_before_hooks $(($1 + 1))
  fi
}

shellspec_call_after_hooks() {
  if [ $# -eq 0 ]; then
    shellspec_call_after_hooks "$SHELLSPEC_AFTER_INDEX"
  else
    [ "$1" -lt 1 ] && return 0
    shellspec_call_hook "SHELLSPEC_AFTER_$1" || return $?
    shellspec_call_after_hooks $(($1 - 1))
  fi
}

shellspec_call_hook() {
  eval "SHELLSPEC_HOOK=\${$1%:*} SHELLSPEC_HOOK_LINENO=\${$1#*:}"
  eval "$SHELLSPEC_HOOK" &&:
  SHELLSPEC_HOOK_STATUS=$?
  return $SHELLSPEC_HOOK_STATUS
}
