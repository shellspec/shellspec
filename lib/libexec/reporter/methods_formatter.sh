#shellcheck shell=sh

: "${field_type:-}"
: "${field_shell:-} ${field_shell_type:-} ${field_shell_version:-}"

create_buffers methods

methods_each() {
  case $field_type in (meta)
    methods '=' "Running: $field_shell "
    if [ "$field_shell_version" ]; then
      methods '+=' "[${field_shell_type} ${field_shell_version}]${LF}"
    else
      methods '+=' "[${field_shell_type}]${LF}"
    fi
  esac
}

methods_output() {
  methods '>>>'
}
