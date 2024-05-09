#shellcheck shell=sh

shellspec_syntax 'shellspec_subject_variable'

shellspec_subject_variable() {
  shellspec_syntax_param count [ $# -ge 1 ] || return 0

  # shellcheck disable=SC2034
  SHELLSPEC_META="variable:$1"
  if eval "[ \${$1+x} ] &&:"; then
    eval "SHELLSPEC_SUBJECT=\${$1}"
  else
    unset SHELLSPEC_SUBJECT ||:
  fi
  shift

  case $# in
    0) shellspec_syntax_dispatch modifier ;;
    *) shellspec_syntax_dispatch modifier "$@" ;;
  esac
}
