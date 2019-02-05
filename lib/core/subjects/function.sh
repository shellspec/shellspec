#shellcheck shell=sh

# to suppress shellcheck SC2034
: "${SHELLSPEC_SUBJECT:-}"

shellspec_syntax 'shellspec_subject_function'

shellspec_subject_function() {
  shellspec_syntax_param count [ $# -ge 1 ] || return 0

  eval "SHELLSPEC_SUBJECT=$($1)"
  shift

  eval shellspec_syntax_dispatch modifier ${1+'"$@"'}
}
