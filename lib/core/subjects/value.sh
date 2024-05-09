#shellcheck shell=sh

shellspec_syntax 'shellspec_subject_value'
shellspec_syntax_alias 'shellspec_subject_function' 'shellspec_subject_value'

shellspec_subject_value() {
  shellspec_syntax_param count [ $# -ge 1 ] || return 0

  # shellcheck disable=SC2034
  SHELLSPEC_META='text'
  # shellcheck disable=SC2034
  SHELLSPEC_SUBJECT=$1
  shift

  case $# in
    0) shellspec_syntax_dispatch modifier ;;
    *) shellspec_syntax_dispatch modifier "$@" ;;
  esac
}
