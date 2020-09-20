#shellcheck shell=sh disable=SC2154

create_buffers methods

methods_each() {
  case $field_type in (meta)
    _shell=$field_shell _type=$field_shell_type \
    _version="${field_shell_version:+ }${field_shell_version}" \
    _info="${field_info:+ }${field_info}"
    methods '=' "Running: $_shell [${_type}${_version}]${_info}${LF}"
  esac
}

methods_output() {
  methods '>>>'
}
