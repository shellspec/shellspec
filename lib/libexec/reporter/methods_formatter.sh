#shellcheck shell=sh disable=SC2004,SC2034

: "${field_type:-}"
: "${field_shell:-} ${field_shell_type:-} ${field_shell_version:-}"

buffer methods

methods_formatter() {
  methods_format() {
    methods '='
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
    case $1 in
      format) methods '>>' ;;
    esac
  }
}
