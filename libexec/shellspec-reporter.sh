#!/bin/sh
#shellcheck disable=SC2004,SC2016

set -eu

echo $$ > "$SHELLSPEC_TMPBASE/reporter_pid"

: "${SHELLSPEC_SPEC_FAILURE_CODE:=101}"

# shellcheck source=lib/libexec/reporter.sh
. "${SHELLSPEC_LIB:-./lib}/libexec/reporter.sh"
use import reset_params each

interrupt='' aborted=1 no_examples=''
if (trap - INT) 2>/dev/null; then trap 'interrupt=1' INT; fi
if (trap - TERM) 2>/dev/null; then trap '' TERM; fi

import "color_schema"
color_constants "${SHELLSPEC_COLOR:-}"

: "${SHELLSPEC_FORMATTER:=debug}"

import "formatter"
import "${SHELLSPEC_FORMATTER}_formatter"
"${SHELLSPEC_FORMATTER##*/}_formatter" "$@"

syntax_error() {
  putsn "Syntax error: ${*:-} in ${field_specfile:-} line ${field_range:-}" >&2
}

parse_metadata() {
  read -r metadata
  set -- "${metadata#?}"
  reset_params '$1' "$US"
  eval "$RESET_PARAMS"
  callback() { eval "meta_${1%%:*}=\${1#*:}"; }
  each callback "$@"
}

parse_lines() {
  buf=''
  while IFS= read -r line || [ "$line" ]; do
    case $line in
      $RS*)
        [ -z "$buf" ] || parse_fields "$1" "$buf"
        buf=${line#?} ;;
      $EOT) aborted='' && break ;;
      *) buf="$buf${buf:+$LF}${line}"
    esac
    [ "$fail_fast" ] && aborted='' && break
  done
  [ -z "$buf" ] || parse_fields "$1" "$buf"
}

parse_fields() {
  callback="$1"

  reset_params '$2' "$US"
  eval "$RESET_PARAMS"

  for field in "$@"; do
    eval "field_${field%%:*}=\${field#*:}"
    set -- "$@" "${field%%:*}"
    shift
  done

  "$callback" "$@"

  for field_name in "$@"; do
    # mksh @(#)MIRBSD KSH R39 2010/07/25: Many unset cause a Segmentation fault
    # eval "unset field_$field_name ||:"
    eval "field_$field_name=''"
  done
}

exit_status=0 fail_fast='' found_focus=''
fail_fast_count=${SHELLSPEC_FAIL_FAST_COUNT:-}

parse_metadata
formatter_begin

# shellcheck disable=SC2034
{
  current_example_index=0 example_index='' detail_index=0
  last_block_no='' last_example_no='' last_skip_id='' last_skipped_id=''
  total_count=0 succeeded='' succeeded_count='' failed_count='' warned_count=''
  todo_count='' fixed_count='' skipped_count='' suppressed_skipped_count=''
  field_example_no='' field_tag='' field_type=''
}

each_line() {
  example_index=$current_example_index

  if [ "$field_type" = "begin" ]; then
    if [ "$field_tag" = "specfile" ]; then
      last_block_no='' last_example_no=''
      eval last_skip_id='' last_skipped_id=''
    else
      if [ "${field_block_no:-0}" -le "${last_block_no:-0}" ]; then
        syntax_error "Illegal executed the same block"
        echo "(For example, do not include blocks in a loop)" >&2
        exit 1
      fi
      last_block_no=$field_block_no
    fi
  fi

  # Do not add references if example_index is blank
  case $field_tag in (good|succeeded)
    [ "${field_pending:-}" ] || example_index=''
  esac

  case $field_tag in (skip|skipped)
    case ${SHELLSPEC_SKIP_MESSAGE:-} in (quiet)
      [ "${field_conditional:-}" ] && example_index=''
    esac
    case ${SHELLSPEC_SKIP_MESSAGE:-} in (moderate|quiet)
      eval "
        [ \"\$field_skipid\" = \"\$last_${field_tag}_id\" ] && example_index=''
        last_${field_tag}_id=\${field_skipid:-}
      "
    esac
  esac

  if [ "$example_index" ]; then
    case $field_tag in (good|bad|warn|skip|pending)
      # Increment example_index if change example_no
      if [ "$field_example_no" != "$last_example_no" ];then
        current_example_index=$(($current_example_index + 1)) detail_index=0
        example_index=$current_example_index last_example_no=$field_example_no
      fi
      detail_index=$(($detail_index + 1))
    esac
  fi

  if [ "$field_type" = "result" ]; then
    total_count=$(($total_count + 1))
    eval "${field_tag}_count=\$((\$${field_tag}_count + 1))"
    if [ "$field_tag" = "skipped" ] && [ -z "$example_index" ]; then
      suppressed_skipped_count=$((${suppressed_skipped_count:-0} + 1))
    fi
  fi

  [ "${field_error:-}" ] && exit_status=$SHELLSPEC_SPEC_FAILURE_CODE
  [ "${field_focused:-}" = "focus" ] && found_focus=1
  [ "${failed_count:-0}" -ge "${fail_fast_count:-99999999}" ] && fail_fast=1

  color_schema
  formatter_format "$@"
}
parse_lines each_line

[ "$aborted" ] && exit_status=1
[ "$interrupt" ] && exit_status=130
if [ "${SHELLSPEC_FAIL_NO_EXAMPLES:-}" ] && [ "$total_count" -eq 0 ]; then
  #shellcheck disable=SC2034
  no_examples=1 exit_status=$SHELLSPEC_SPEC_FAILURE_CODE
fi

callback() { [ -e "$SHELLSPEC_TIME_LOG" ] || sleep 0; }
shellspec_sequence callback 1 10
read_time_log "time" "$SHELLSPEC_TIME_LOG"

formatter_end

if [ "$found_focus" ] && [ ! "${SHELLSPEC_FOCUS:-}" ]; then
  warn "To run focused example only, you need to specify --focus option."
fi

exit "$exit_status"
