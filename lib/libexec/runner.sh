#shellcheck shell=sh

shellspec_proxy includes shellspec_includes

mktempdir() {
  (umask 0077; mkdir "$1"; chmod 0700 "$1")
}

rmtempdir() {
  rm -rf "$1" >/dev/null 2>&1
}

time_result() {
  case ${1%% *} in ( real | user | sys )
    case ${1##* } in ( *[!0-9.]* ) return 1; esac
    echo "$1" && return 0
  esac
  return 1
}
