#shellcheck shell=sh disable=SC2016

shellspec_output() {
  # shellcheck disable=SC2145
  "shellspec_output_$@"
}

shellspec_output_raw() {
  [ $# -gt 0 ] || return 0

  case $1 in (begin | end | statement | result)
    # shellcheck disable=SC2145
    set -- "type:$@" "id:${SHELLSPEC_ID:-}" "block_no:${SHELLSPEC_BLOCK_NO:-}" \
      "specfile:${SHELLSPEC_SPECFILE:-}" "focused:${SHELLSPEC_FOCUSED:-}" \
      "range:${SHELLSPEC_LINENO_BEGIN:-}-${SHELLSPEC_LINENO_END:-}" \
      "desc:$SHELLSPEC_DESC" "description:$SHELLSPEC_DESCRIPTION"
  esac
  case ${1#type:} in (statement | result)
    set -- "$@" "example_no:${SHELLSPEC_EXAMPLE_NO:-}" \
      "lineno:${SHELLSPEC_LINENO:-$SHELLSPEC_LINENO_BEGIN}" \
      "evaluation:${SHELLSPEC_EVALUATION:-}" "pending:${SHELLSPEC_PENDING:-}"
  esac

  shellspec_output_buf="${shellspec_output_buf:-}$SHELLSPEC_RS"
  while [ $# -gt 1 ]; do
    shellspec_output_buf="${shellspec_output_buf}$1${SHELLSPEC_US}"
    shift
  done
  shellspec_puts "${shellspec_output_buf}$1"
  shellspec_output_buf=$SHELLSPEC_LF
}

shellspec_output_raw_append() {
  shellspec_putsn "${SHELLSPEC_US}$*"
}

shellspec_output_if() {
  shellspec_if "$1" || return 1
  shellspec_output "$@"
}

shellspec_output_unless() {
  shellspec_unless "$1" || return 1
  shellspec_output "$@"
}

shellspec_output_failure_message() {
  shellspec_puts "${SHELLSPEC_US}failure_message:"
  shellspec_matcher__failure_message \
    "$(shellspec_output_subject)" "$(shellspec_output_expect)"
}

shellspec_output_failure_message_when_negated() {
  shellspec_puts "${SHELLSPEC_US}failure_message:"
  shellspec_matcher__failure_message_when_negated \
    "$(shellspec_output_subject)" "$(shellspec_output_expect)"
}

shellspec_output_following_words() {
  eval "
    shellspec_reset_params '\${SHELLSPEC_SYNTAXES#|}' '|'
    eval \"\$SHELLSPEC_RESET_PARAMS\"
    callback() { case \${1#$1_} in (*_*) return 1; esac; }
    shellspec_find callback \"\$@\"
    eval \"\$SHELLSPEC_RESET_PARAMS\"
    callback() {
      [ \$(( (\$2 - 1) % 8)) -eq 0 ] && shellspec_puts '  '
      shellspec_puts \"\${1#$1_}\"
      [ \$2 -eq \$3 ] || shellspec_puts ', '
      [ \$(( \$2 % 8)) -ne 0 ] || shellspec_puts \"\$SHELLSPEC_LF\"
    }
    shellspec_putsn
    shellspec_each callback \"\$@\"
    shellspec_putsn
  "
}

shellspec_output_syntax_name() {
  [ "${SHELLSPEC_SYNTAX_NAME:-}" ] || return 0
  shellspec_reset_params '${SHELLSPEC_SYNTAX_NAME#shellspec_}' '_'
  eval "$SHELLSPEC_RESET_PARAMS"
  eval "shift; shellspec_putsn \"\$*\" \"$1\""
}

shellspec_output_subject() {
  if [ ${SHELLSPEC_SUBJECT+x} ]; then
    if  shellspec_is number "${SHELLSPEC_SUBJECT}"; then
      shellspec_puts "${SHELLSPEC_SUBJECT}"
    else
      shellspec_puts "\"${SHELLSPEC_SUBJECT}\""
    fi
  else
    shellspec_puts "<unset>"
  fi
}

shellspec_output_expect() {
  if [ ${SHELLSPEC_EXPECT+x} ]; then
    if  shellspec_is number "${SHELLSPEC_EXPECT}"; then
      shellspec_puts "${SHELLSPEC_EXPECT}"
    else
      shellspec_puts "\"${SHELLSPEC_EXPECT}\""
    fi
  else
    shellspec_puts "<unset>"
  fi
}
