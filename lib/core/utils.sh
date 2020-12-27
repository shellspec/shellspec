#shellcheck shell=sh disable=SC2016

shellspec_is_number() {
  case ${1:-} in ( '' | *[!0-9]* ) return 1; esac
  return 0
}

shellspec_is_function() {
  case ${1:-} in ([a-zA-Z_]*) ;; (*) return 1; esac
  case ${1:-} in (*[!a-zA-Z0-9_]*) return 1; esac
  return 0
}

shellspec_is_identifier() {
  case ${1:-} in ([a-zA-Z_]*) ;; (*) return 1; esac
  case ${1:-} in (*[!a-zA-Z0-9_]*) return 1; esac
  return 0
}

shellspec_proxy shellspec_append_shell_option shellspec_append_set
if [ "${SHELLSPEC_SHOPT_AVAILABLE:-}" ]; then
  shellspec_proxy shellspec_append_shell_option shellspec_append_shopt
fi

# Workaround for mksh, pdksh, posh. it can not be set -e within eval.
# shellcheck disable=SC2034
SHELLSPEC_SET_OPTION=${SHELLSPEC_DEFECT_SETE:+shellspec_set_option}

shellspec_append_set() {
  case $2 in
    *:on ) eval "$1=\"\${$1}set -o ${2%:*};\"" ;;
    *:off) eval "$1=\"\${$1}set +o ${2%:*};\"" ;;
        *) shellspec_error "shellspec_shell_option: invalid option '$1'"
  esac
}

shellspec_append_shopt() {
  case $2 in
    *:on ) eval "$1=\"\${$1}shellspec_shopt -o ${2%:*};\"" ;;
    *:off) eval "$1=\"\${$1}shellspec_shopt +o ${2%:*};\"" ;;
        *) shellspec_error "shellspec_shell_option: invalid option '$1'"
  esac
}

shellspec_set_option() {
  #shellcheck disable=SC2153
  set -- "$SHELLSPEC_SHELL_OPTIONS"
  while [ "$1" ]; do
    set -- "${1#*;}" "${1%%;*}"
    case $2 in
      set\ -o*) shellspec_set_long -"${2#set -o }" ;;
      set\ +o*) shellspec_set_long +"${2#set +o }" ;;
    esac
  done
}

shellspec_shopt() {
  #shellcheck disable=SC2039
  case $1 in
    -o) shopt -s "$2" 2>/dev/null || set -o "$2" ;;
    +o) shopt -u "$2" 2>/dev/null || set +o "$2" ;;
  esac
}

shellspec_set_long() {
  set "${1%%[a-zA-Z]*}o" "${1#?}"
}
