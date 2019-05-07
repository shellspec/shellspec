#shellcheck shell=sh disable=SC2004,SC2034

: "${field_type:-}"
: "${field_shell:-} ${field_shell_type:-} ${field_shell_version:-}"

methods_format() {
  case $field_type in (meta)
    putsn "Running: $field_shell" \
      "[${field_shell_type}${field_shell_version:+ }${field_shell_version}]"
  esac
}
