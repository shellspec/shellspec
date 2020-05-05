#shellcheck shell=sh disable=SC2004

shellspec_create_hook() {
  eval "SHELLSPEC_BEFORE_$1_INDEX=0 SHELLSPEC_AFTER_$1_INDEX=0"
}

shellspec_register_hook() {
  SHELLSPEC_EVAL="
    shift 2; \
    while [ \$# -gt 0 ]; do \
      SHELLSPEC_$1_$2_INDEX=\$((\$SHELLSPEC_$1_$2_INDEX + 1)); \
      shellspec_hook_index $1 $2 \$SHELLSPEC_$1_$2_INDEX \"\$1\"; \
      shift; \
    done; \
  "
  eval "$SHELLSPEC_EVAL"
}

shellspec_proxy shellspec_register_before_hook "shellspec_register_hook BEFORE"
shellspec_proxy shellspec_register_after_hook "shellspec_register_hook AFTER"

shellspec_hook_index() {
  eval "SHELLSPEC_$1_$2_$3=\$SHELLSPEC_GROUP_ID#\$SHELLSPEC_AUX_LINENO:\$4"
}

shellspec_call_hook() {
  eval "set -- \"\$1\" \"\${SHELLSPEC_$1_$2#*:}\" \"\${SHELLSPEC_$1_$2%%:*}\""
  # shellcheck disable=SC2034
  SHELLSPEC_HOOK_GROUP_ID=${3%#*} SHELLSPEC_HOOK_LINENO=${3#*#}
  eval "SHELLSPEC_HOOK=\$2 && $2 &&:" &&:
  SHELLSPEC_HOOK_STATUS=$?
  return $SHELLSPEC_HOOK_STATUS
}

shellspec_call_before_hooks() {
  if [ $# -le 1 ]; then
    shellspec_call_before_hooks "$1" 1
  else
    eval "[ \"\${2:-1}\" -gt \"\$SHELLSPEC_BEFORE_$1_INDEX\" ] &&:" && return 0
    shellspec_call_hook "BEFORE_$1" "${2:-1}" || return $?
    shellspec_call_before_hooks "$1" "$((${2:-1} + 1))"
  fi
}

shellspec_call_after_hooks() {
  if [ $# -le 1 ]; then
    eval "set -- \"\$1\" \"\$SHELLSPEC_AFTER_$1_INDEX\""
    shellspec_call_after_hooks "$1" "$2"
  else
    [ "$2" -lt 1 ] && return 0
    shellspec_call_hook "AFTER_$1" "$2" || return $?
    shellspec_call_after_hooks "$1" $(($2 - 1))
  fi
}

shellspec_create_hook EACH
shellspec_create_hook CALL
shellspec_create_hook RUN
