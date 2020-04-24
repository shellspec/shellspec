#shellcheck shell=sh disable=SC2016

shellspec_is() {
  case $1 in
    number) case ${2:-} in ( '' | *[!0-9]* ) return 1; esac ;;
    funcname) shellspec_is_function "${2:-}" || return 1 ;;
    *) shellspec_error "shellspec_is: invalid type name '$1'"
  esac
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

shellspec_capture() {
  SHELLSPEC_EVAL="
    if $1=\"\$($2 && echo _)\"; then $1=\${$1%_}; else unset $1 ||:; fi
  "
  eval "$SHELLSPEC_EVAL"
}

SHELLSPEC_SHELL_OPTION=""
shellspec_proxy shellspec_append_shell_option shellspec_append_set
if [ "${BASH_VERSION:-}" ]; then
  shellspec_proxy shellspec_append_shell_option shellspec_append_shopt
fi

# Workaround for mksh, pdksh, posh. it can not be set within eval.
if ( set +e; eval "set -e"; case $- in (*e*) false; esac ); then
  #shellcheck disable=SC2034
  SHELLSPEC_SHELL_OPTION="shellspec_set_option"
fi

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
