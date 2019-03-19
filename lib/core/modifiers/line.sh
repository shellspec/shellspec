#shellcheck shell=sh

shellspec_syntax 'shellspec_modifier_line'

shellspec_modifier_line() {
  shellspec_syntax_param count [ $# -ge 1 ] || return 0
  shellspec_syntax_param 1 is number "$1" || return 0

  if [ "${SHELLSPEC_SUBJECT+x}" ] && [ "${SHELLSPEC_SUBJECT:-}" ]; then
    eval "
      shellspec_callback() {
        [ \$2 -eq $1 ] && SHELLSPEC_SUBJECT=\$1 && return 1
        unset SHELLSPEC_SUBJECT ||:
      }
    "
    shellspec_lines shellspec_callback "$SHELLSPEC_SUBJECT"
  else
    unset SHELLSPEC_SUBJECT ||:
  fi
  shift

  eval shellspec_syntax_dispatch modifier ${1+'"$@"'}
}
