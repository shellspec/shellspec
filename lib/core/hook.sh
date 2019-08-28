#shellcheck shell=sh disable=SC2004

shellspec_create_hook() {
  eval "SHELLSPEC_BEFORE_$1_INDEX=0 SHELLSPEC_AFTER_$1_INDEX=0"
}

shellspec_register_hook() {
  SHELLSPEC_EVAL="
    shift 2; \
    while [ \$# -gt 0 ]; do \
      SHELLSPEC_$1_$2_INDEX=\$((\$SHELLSPEC_$1_$2_INDEX + 1)); \
      shellspec_hook_index SHELLSPEC_$1_$2_\$SHELLSPEC_$1_$2_INDEX \"\$1\"; \
      shift; \
    done
  "
  eval "$SHELLSPEC_EVAL"
}

shellspec_proxy shellspec_register_before_hook "shellspec_register_hook BEFORE"
shellspec_proxy shellspec_register_after_hook "shellspec_register_hook AFTER"

shellspec_hook_index() {
  eval "$1=\$SHELLSPEC_SPEC_NO@\${SHELLSPEC_GROUP_ID:-}@\$SHELLSPEC_AUX_LINENO:\$2"
}

shellspec_call_hook() {
  eval "SHELLSPEC_HOOK=\${$2#*:} SHELLSPEC_HOOK_ID=\${$2%:*}"
  #shellcheck disable=SC2034
  SHELLSPEC_HOOK_LINENO=${SHELLSPEC_HOOK_ID##*@}

  case $1 in
    BEFORE-ALL) shellspec_marked_tag "$SHELLSPEC_HOOK_ID" && return 0 ;;
    AFTER-ALL)
      [ "${SHELLSPEC_HOOK_ID%@*}" = "$SHELLSPEC_SPEC_NO@${SHELLSPEC_GROUP_ID:-}" ] || return 0
      shellspec_marked_tag "${SHELLSPEC_HOOK_ID%@*}" || return 0
  esac

  eval "$SHELLSPEC_HOOK &&:" &&:
  SHELLSPEC_HOOK_STATUS=$?

  case $1 in
    BEFORE-ALL) shellspec_mark_tag "$SHELLSPEC_HOOK_ID"
  esac

  return $SHELLSPEC_HOOK_STATUS
}

shellspec_call_before_hooks() {
  if [ $# -le 1 ]; then
    shellspec_call_before_hooks "$1" 1
  else
    eval "[ \"\${2:-1}\" -gt \"\$SHELLSPEC_BEFORE_$1_INDEX\" ] &&:" && return 0
    shellspec_call_hook "BEFORE-$1" "SHELLSPEC_BEFORE_$1_${2:-1}" || return $?
    shellspec_call_before_hooks "$1" "$((${2:-1} + 1))"
  fi
}

shellspec_call_after_hooks() {
  if [ $# -le 1 ]; then
    eval "set -- \"\$1\" \"\$SHELLSPEC_AFTER_$1_INDEX\""
    shellspec_call_after_hooks "$1" "$2"
  else
    [ "$2" -lt 1 ] && return 0
    shellspec_call_hook "AFTER-$1" "SHELLSPEC_AFTER_$1_$2" || return $?
    shellspec_call_after_hooks "$1" $(($2 - 1))
  fi
}

shellspec_mark_executed_group() {
  shellspec_mark_tag "$SHELLSPEC_SPEC_NO@$1"
  case $1 in
    *-*) shellspec_mark_executed_group "${1%-*}" ;;
    *) shellspec_mark_tag "$SHELLSPEC_SPEC_NO@"
  esac
}

shellspec_mark_tag() {
  [ -e "$SHELLSPEC_TMPBASE/$1" ] || : > "$SHELLSPEC_TMPBASE/$1"
}

shellspec_marked_tag() {
  [ -e "$SHELLSPEC_TMPBASE/$1" ]
}

shellspec_create_hook EACH
shellspec_create_hook CALL
shellspec_create_hook RUN
shellspec_create_hook ALL
