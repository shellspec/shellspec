#shellcheck shell=sh

shellspec_enum_file_descriptors() {
  set -- "$1" "$2:"
  while [ "${2%%:*}" ]; do
    set -- "$1" "${2#*:}" "${2%%:*}"
    "$1" "$3" "$SHELLSPEC_STDIO_FILE_BASE.fd-$3"
  done
}

shellspec_open_file_descriptors() {
  set -- "$1:"
  while [ "${1%%:*}" ]; do
    set -- "${1#*:}" "${1%%:*}"
    case $2 in ([0-9])
      shellspec_open_file_descriptor "$2" "$SHELLSPEC_STDIO_FILE_BASE.fd-$2"
      continue
    esac
    if [ "$SHELLSPEC_FDVAR_AVAILABLE" ]; then
      shellspec_is_identifier "$2" || continue
      shellspec_open_file_descriptor "{$2}" "$SHELLSPEC_STDIO_FILE_BASE.fd-$2"
    fi
  done
}

shellspec_open_file_descriptor() {
  eval "exec $1>\"\$2\""
}

shellspec_close_file_descriptors() {
  set -- "$1:"
  while [ "${1%%:*}" ]; do
    set -- "${1#*:}" "${1%%:*}"
    case $2 in ([0-9])
      shellspec_close_file_descriptor "$2"
      continue
    esac
    if [ "$SHELLSPEC_FDVAR_AVAILABLE" ]; then
      shellspec_is_identifier "$2" || continue
      shellspec_close_file_descriptor "{$2}"
    fi
  done
}

shellspec_close_file_descriptor() {
  eval "exec $1>&-"
}
