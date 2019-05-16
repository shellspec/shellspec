#shellcheck shell=sh disable=SC2004,SC2034

: "${field_type:-}"
: "${field_shell:-} ${field_shell_type:-} ${field_shell_version:-}"

buffer methods

methods_formatter() {
  methods_format() {
    methods clear
    case $field_type in (meta)
      methods append "Running: $field_shell" \
        "[${field_shell_type}${field_shell_version:+ }${field_shell_version}]"
    esac
  }

  methods_output() {
    case $1 in
      format) methods output ;;
    esac
  }
}
