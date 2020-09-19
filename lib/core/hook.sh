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
  eval "SHELLSPEC_$1_$2_$3=\$SHELLSPEC_BLOCK_NO#\$SHELLSPEC_AUX_LINENO:\$4"
}

shellspec_call_hook() {
  eval "set -- \"\$1\" \"\${SHELLSPEC_$1_$2#*:}\" \"\${SHELLSPEC_$1_$2%%:*}\""
  # shellcheck disable=SC2034
  SHELLSPEC_HOOK_BLOCK_NO=${3%\#*} SHELLSPEC_HOOK_LINENO=${3#*\#}

  case $1 in
    BEFORE_ALL)
      shellspec_is_marked_group "$SHELLSPEC_HOOK_BLOCK_NO" && return 0
      ;;
    AFTER_ALL)
      [ "$SHELLSPEC_HOOK_BLOCK_NO" = "$SHELLSPEC_BLOCK_NO" ] || return 0
      shellspec_is_marked_group "$SHELLSPEC_HOOK_BLOCK_NO" || return 0
      ;;
    AFTER_MOCK)
      [ "$SHELLSPEC_HOOK_BLOCK_NO" = "$SHELLSPEC_BLOCK_NO" ] || return 0
    ;;
  esac

  { eval "SHELLSPEC_HOOK=\$2 && $2 &&:" &&:; } < /dev/null
  SHELLSPEC_HOOK_STATUS=$?
  return $SHELLSPEC_HOOK_STATUS
}

shellspec_call_before_hooks() {
  [ $# -lt 2 ] && set -- "$1" 1
  eval "[ \"\$2\" -gt \"\$SHELLSPEC_BEFORE_$1_INDEX\" ] &&:" && return 0
  shellspec_call_hook "BEFORE_$1" "$2" 2>"$SHELLSPEC_ERROR_FILE" || return 1
  [ -s "$SHELLSPEC_ERROR_FILE" ] && return 1
  shellspec_call_before_hooks "$1" "$(($2 + 1))"
}

shellspec_call_after_hooks() {
  [ $# -lt 2 ] && eval "set -- \"\$1\" \"\$SHELLSPEC_AFTER_$1_INDEX\""
  [ "$2" -lt 1 ] && return 0
  shellspec_call_hook "AFTER_$1" "$2" 2>"$SHELLSPEC_ERROR_FILE" || return 1
  [ -s "$SHELLSPEC_ERROR_FILE" ] && return 1
  shellspec_call_after_hooks "$1" $(($2 - 1))
}

shellspec_call_before_evaluation_hooks() {
  [ $# -lt 2 ] && set -- "$1" 1
  eval "[ \"\$2\" -gt \"\$SHELLSPEC_BEFORE_$1_INDEX\" ] &&:" && return 0
  shellspec_call_hook "BEFORE_$1" "$2" || return $?
  shellspec_call_before_evaluation_hooks "$1" "$(($2 + 1))"
}

shellspec_call_after_evaluation_hooks() {
  [ $# -lt 2 ] && eval "set -- \"\$1\" \"\$SHELLSPEC_AFTER_$1_INDEX\""
  [ "$2" -lt 1 ] && return 0
  shellspec_call_hook "AFTER_$1" "$2" || return $?
  shellspec_call_after_evaluation_hooks "$1" $(($2 - 1))
}

shellspec_mark_group() {
  eval "SHELLSPEC_MARK_${1:-0}=\${2:-}"
}

shellspec_is_marked_group() {
  eval "[ \"\$SHELLSPEC_MARK_${1:-0}\" ] &&:" &&:
}

shellspec_create_hook EACH
shellspec_create_hook CALL
shellspec_create_hook RUN
shellspec_create_hook ALL
shellspec_create_hook MOCK
