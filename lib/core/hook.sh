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
  eval "SHELLSPEC_$1_$2_$3=\$4:\${SHELLSPEC_AUX_LINENO:-}"
}

shellspec_call_hook() {
  eval "SHELLSPEC_HOOK=\${$1%:*} SHELLSPEC_HOOK_LINENO=\${$1#*:}"
  eval "$SHELLSPEC_HOOK &&:" &&:
  SHELLSPEC_HOOK_STATUS=$?
  return $SHELLSPEC_HOOK_STATUS
}

shellspec_call_before_hooks() {
  eval "[ \"\${2:-1}\" -gt \"\$SHELLSPEC_BEFORE_$1_INDEX\" ] &&:" && return 0
  shellspec_call_hook "SHELLSPEC_BEFORE_$1_${2:-1}" || return $?
  shellspec_call_before_hooks "$1" "$((${2:-1} + 1))"
}

shellspec_call_after_hooks() {
  [ $# -le 1 ] && eval "set -- \"\$1\" \"\$SHELLSPEC_AFTER_$1_INDEX\""
  [ "$2" -lt 1 ] && return 0
  shellspec_call_hook "SHELLSPEC_AFTER_$1_$2" || return $?
  shellspec_call_after_hooks "$1" $(($2 - 1))
}

shellspec_create_hook EACH
shellspec_create_hook CALL
shellspec_create_hook RUN
