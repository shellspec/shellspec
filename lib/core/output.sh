#shellcheck shell=sh disable=SC2016

shellspec_output() {
  # shellcheck disable=SC2145
  "shellspec_output_$@"
}

shellspec_output_to_fd() {
  # shellcheck disable=SC2039,SC3021
  "$@" >&"$SHELLSPEC_OUTPUT_FD"
}

shellspec_output_raw() {
  [ $# -gt 0 ] || return 0

  shellspec_output_buf="${shellspec_output_buf:-}${SHELLSPEC_RS}"
  while [ $# -gt 1 ]; do
    shellspec_output_buf="${shellspec_output_buf}$1${SHELLSPEC_US}"
    shift
  done
  shellspec_output_to_fd shellspec_puts "${shellspec_output_buf}$1"
  shellspec_output_buf=$SHELLSPEC_LF
}

shellspec_output_raw_append() {
  shellspec_output_to_fd shellspec_puts "$SHELLSPEC_US"
  shellspec_output_to_fd shellspec_putsn "$@"
}

shellspec_output_meta() {
  eval shellspec_output_raw type:meta ${1:+'"$@"'}
}

shellspec_output_finished() {
  eval shellspec_output_raw type:finished ${1:+'"$@"'}
}

shellspec_output_begin() {
  eval shellspec_output_raw type:begin ${1:+'"$@"'}
}

shellspec_output_end() {
  eval shellspec_output_raw type:end ${1:+'"$@"'}
}

shellspec_output_example() {
  eval shellspec_output_raw type:example ${1:+'"$@"'} \
    "lineno_range:${SHELLSPEC_LINENO_BEGIN}-${SHELLSPEC_LINENO_END}"
}

shellspec_output_statement() {
  eval shellspec_output_raw type:statement ${1:+'"$@"'} \
    "lineno:${SHELLSPEC_LINENO:-$SHELLSPEC_LINENO_BEGIN}"
}

shellspec_output_result() {
  [ "$SHELLSPEC_XTRACE" ] && set -- "$@" "trace:$SHELLSPEC_XTRACE_FILE"
  shellspec_output_raw type:result "$@"
}

shellspec_output_error() {
  shellspec_output_raw type:error "$@"
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
  shellspec_output_to_fd shellspec_puts "${SHELLSPEC_US}failure_message:"
  set -- "$(shellspec_output_subject)" "$(shellspec_output_expect)"
  shellspec_output_to_fd shellspec_matcher__failure_message "$@"
}

shellspec_output_failure_message_when_negated() {
  shellspec_output_to_fd shellspec_puts "${SHELLSPEC_US}failure_message:"
  set -- "$(shellspec_output_subject)" "$(shellspec_output_expect)"
  shellspec_output_to_fd shellspec_matcher__failure_message_when_negated "$@"
}

shellspec_output_assert_message() {
  shellspec_output_to_fd shellspec_putsn "$1"
}

shellspec_output_following_words() {
  set -- "$1" "${SHELLSPEC_SYNTAXES#:}" "" ""

  while [ "$2" ] && set -- "$1" "${2#*:}" "${2%%:*}" "$4"; do
    eval "set -- \"\$@\" \${3#${1}_}"
    case $5 in (*_*) continue; esac
    set -- "$1" "$2" "$3" "$4${4:+ }$5"
  done
  eval "set -- $4"

  callback() {
    [ $(( ($2 - 1) % 8)) -eq 0 ] && shellspec_puts '  '
    shellspec_puts "$1"
    [ "$2" -eq "$3" ] || shellspec_puts ', '
    [ $(( $2 % 8)) -ne 0 ] || shellspec_puts "$SHELLSPEC_LF"
  }
  shellspec_output_to_fd shellspec_putsn
  shellspec_output_to_fd shellspec_each callback "$@"
  shellspec_output_to_fd shellspec_putsn
}

shellspec_output_syntax_name() {
  [ "${SHELLSPEC_SYNTAX_NAME:-}" ] || return 0
  set -- "${SHELLSPEC_SYNTAX_NAME#shellspec_}"
  set -- "${1#*_}_${1%%_*}_" "" ""
  while [ "$1" ] && set -- "${1#*_}" "${1%%_*}" "$3"; do
    set -- "$1" "$2" "$3${3:+ }$2"
  done
  shellspec_putsn "$3"
}

shellspec_output_subject() {
  if [ ${SHELLSPEC_SUBJECT+x} ]; then
    if  shellspec_is_number "${SHELLSPEC_SUBJECT}"; then
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
    if  shellspec_is_number "${SHELLSPEC_EXPECT}"; then
      shellspec_puts "${SHELLSPEC_EXPECT}"
    else
      shellspec_puts "\"${SHELLSPEC_EXPECT}\""
    fi
  else
    shellspec_puts "<unset>"
  fi
}
