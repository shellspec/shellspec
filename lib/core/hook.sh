#shellcheck shell=sh disable=SC2004

shellspec_create_hook() {
  SHELLSPEC_EVAL="
    SHELLSPEC_$2_INDEX=0; \
    shellspec_$1_hook() { \
      while [ \$# -gt 0 ]; do \
        SHELLSPEC_$2_INDEX=\$((\$SHELLSPEC_$2_INDEX + 1)); \
        shellspec_register_hook $2 \$SHELLSPEC_$2_INDEX \"\$1\"; \
        shift; \
      done; \
    } \
  "
  eval "$SHELLSPEC_EVAL"
  if [ "${3:-}" = "" ]; then
    SHELLSPEC_EVAL="
      shellspec_call_$1_hooks() { \
        if [ \$# -eq 0 ]; then \
          shellspec_call_$1_hooks 1; \
        else \
          [ \"\$1\" -gt \"\$SHELLSPEC_$2_INDEX\" ] && return 0; \
          shellspec_call_hook \"SHELLSPEC_$2_\$1\" || return \$?; \
          shellspec_call_$1_hooks \$((\$1 + 1)); \
        fi; \
      } \
    "
  else
    SHELLSPEC_EVAL="
      shellspec_call_$1_hooks() { \
        if [ \$# -eq 0 ]; then \
          shellspec_call_$1_hooks \"\$SHELLSPEC_$2_INDEX\"; \
        else \
          [ \"\$1\" -lt 1 ] && return 0; \
          shellspec_call_hook \"SHELLSPEC_$2_\$1\" || return \$?; \
          shellspec_call_$1_hooks \$((\$1 - 1)); \
        fi; \
      }; \
    "
  fi
  eval "$SHELLSPEC_EVAL"
}

shellspec_register_hook() {
  eval "SHELLSPEC_$1_$2=\$3:\${SHELLSPEC_AUX_LINENO:-}"
}

shellspec_call_hook() {
  eval "SHELLSPEC_HOOK=\${$1%:*} SHELLSPEC_HOOK_LINENO=\${$1#*:}"
  eval "$SHELLSPEC_HOOK &&:" &&:
  SHELLSPEC_HOOK_STATUS=$?
  return $SHELLSPEC_HOOK_STATUS
}

shellspec_create_hook before BEFORE
shellspec_create_hook after AFTER rev

shellspec_create_hook before_call BEFORE_CALL
shellspec_create_hook after_call AFTER_CALL rev

shellspec_create_hook before_run BEFORE_RUN
shellspec_create_hook after_run AFTER_RUN rev
