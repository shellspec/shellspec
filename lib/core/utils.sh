#shellcheck shell=sh disable=SC2016

shellspec_readfile() {
  eval "$1=''"
  # shellcheck disable=SC2034
  while IFS= read -r shellspec_buf; do
    eval "$1=\"\${$1}\$shellspec_buf$SHELLSPEC_LF\""
  done < "$2"
  eval "$1=\"\${$1}\$shellspec_buf\""
  unset shellspec_buf
}

shellspec_get_nth() {
  shellspec_reset_params '"$1" "$2" $4' "$3"
  eval "$SHELLSPEC_RESET_PARAMS"
  eval "$1=\${$(($2 + 2)):-}"
}

shellspec_is() {
  case $1 in
    number) case ${2:-} in ( '' | *[!0-9]* ) return 1; esac ;;
    funcname)
      case ${2:-} in ([a-zA-Z_]*) ;; (*) return 1; esac
      case ${2:-} in (*[!a-zA-Z0-9_]*) return 1; esac ;;
    *) shellspec_error "shellspec_is: invalid type name '$1'"
  esac
  return 0
}

shellspec_set() {
  while [ $# -gt 0 ]; do eval "${1%%\=*}=\${1#*\\=}" && shift; done
}
shellspec_unset() {
  while [ $# -gt 0 ]; do eval "unset $1 ||:" && shift; done
}
