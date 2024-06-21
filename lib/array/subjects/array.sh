#shellcheck shell=sh

shellspec_syntax 'shellspec_subject_array'

shellspec_subject_array() {
  # next word in DSL should be the array name
  shellspec_syntax_param count [ $# -ge 1 ] || return 0

  # shellcheck disable=SC2034
  SHELLSPEC_META="array:$1"
  if eval "[ \${$1+x} ] &&:"; then # array is set
    shellspec_copy_array "$1" "SHELLSPEC_SUBJECT"
  else
    unset SHELLSPEC_SUBJECT ||:
  fi
  shift

  eval shellspec_syntax_dispatch modifier ${1+'"$@"'}
}
