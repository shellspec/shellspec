#shellcheck shell=sh disable=SC2154

trace_each() {
  if [ "$field_type" = "result" ] && [ -e "$field_trace" ]; then
    putsn "${LF}[$field_specfile:$field_lineno] $field_evaluation"
    output_trace < "$field_trace"
  fi >> "$SHELLSPEC_LOGFILE"
}
