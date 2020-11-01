#shellcheck shell=sh disable=SC2016

shellspec_syntax 'shellspec_matcher_satisfy'


shellspec_matcher_satisfy() {
  shellspec_matcher__match() {
    SHELLSPEC_SATISFY_STDERR_FILE="$SHELLSPEC_WORKDIR/satisfy.stderr"

    if ! shellspec_is_function "${1:-}"; then
      shellspec_output SYNTAX_ERROR "'$1' is not function name"
      shellspec_on SYNTAX_ERROR
      return 0
    fi

    # shellcheck disable=SC2034
    IFS=" $IFS" && SHELLSPEC_EXPECT="$*" && IFS=${IFS#?}
    shellspec_puts "${SHELLSPEC_SUBJECT:-}" | (
      if shellspec_is_identifier "$1"; then
        if [ "${SHELLSPEC_SUBJECT+x}" ]; then
          eval "$1=\$SHELLSPEC_SUBJECT"
        else
          unset "$1" ||:
        fi
      fi

      "$@"
      ex=$?
      # shellcheck disable=SC2034
      while read -r line; do :; done # Discard unnecessary STDIN data
      set_exit_status() { return "$1"; }
      set_exit_status "$ex"
    ) 2>"$SHELLSPEC_SATISFY_STDERR_FILE" >&4 &&:

    set -- "$?"
    if [ -s "$SHELLSPEC_SATISFY_STDERR_FILE" ]; then
      shellspec_output SATISFY_WARN "$1" "$SHELLSPEC_SATISFY_STDERR_FILE"
      shellspec_on WARNED
    fi
    return "$1"
  }

  shellspec_syntax_failure_message + 'expected $1 satisfies $2'
  shellspec_syntax_failure_message - 'expected $1 does not satisfy $2'

  shellspec_syntax_param count [ $# -gt 0 ] || return 0
  shellspec_matcher_do_match "$@"
}
