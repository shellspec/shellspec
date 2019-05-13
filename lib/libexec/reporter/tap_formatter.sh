#shellcheck shell=sh disable=SC2004

tap_formatter() {
  count "$@"
  load_formatters tap
}
