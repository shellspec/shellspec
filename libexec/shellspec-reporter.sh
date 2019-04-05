#!/bin/sh
#shellcheck disable=SC2004,SC2016

set -eu

# shellcheck source=lib/general.sh
. "${SHELLSPEC_LIB:-./lib}/general.sh"
# shellcheck source=lib/libexec/reporter.sh
. "${SHELLSPEC_LIB:-./lib}/libexec/reporter.sh"

interrupt=''
if (trap '' INT) 2>/dev/null; then
  trap 'if [ "$interrupt" ]; then exit 130; else interrupt=1; fi' INT
fi

import "color_schema"
color_constants "${SHELLSPEC_COLOR:-}"

: "${SHELLSPEC_FORMATTER:=debug}"

import "formatter"
import "${SHELLSPEC_FORMATTER}_formatter"
"${SHELLSPEC_FORMATTER##*/}_formatter"

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
      $CAN)
        [ -z "$buf" ] || parse_fields canceled "$buf"
        buf=''
        exit_status=${SHELLSPEC_SPEC_FAILURE_CODE:-101}
        ;;
      *) buf="$buf${buf:+$LF}${line}"
    esac

    if [ "$fail_fast" ]; then
      break
    fi
  done
  [ -z "$buf" ] || parse_fields "$1" "$buf"
}

parse_fields() {
  callback="$1" field_names=""

  reset_params '$2' "$US"
  eval "$RESET_PARAMS"
  callback() {
    field_names="$field_names ${1%%:*}"
    eval "field_${1%%:*}=\${1#*:}"
  }
  each callback "$@"

  eval "set -- $field_names"
  "$callback" "$@"

  callback() { eval "unset field_$1 ||:"; }
  each callback "$@"
}

canceled() {
  formatter_fatal_error "$@"
}

exit_status=0 fail_fast='' fail_fast_count="${SHELLSPEC_FAIL_FAST_COUNT:-}"

parse_metadata
formatter_begin

# shellcheck disable=SC2034
{
  total_count=0 succeeded='' failed_count='' warned_count=''
  todo_count='' fixed_count='' skipped_count='' suppressed_skipped_count=''
  example_index='' field_example_no='' field_tag='' field_type=''
}

each_line() {
  : "${current_example_index:=0}" "${last_example_no:=}" "${detail_index:=0}"
  : "${last_skip_id:=}" "${last_skipped_id:=}"
  : "${last_skip_specfile:=}" "${last_skipped_specfile:=}"
  example_index=$current_example_index

  if [ "$field_type" = "begin" ]; then
    if [ "${field_specfile:-}" != "${last_specfile:-}" ]; then
      last_block_no=0
      last_specfile=$field_specfile
    fi
    if [ "${field_block_no:-0}" -le "${last_block_no:-0}" ]; then
      syntax_error "Illegal executed the same block"
      echo "(For example, do not include blocks in a loop)" >&2
      exit 1
    fi
    last_block_no=$field_block_no
  fi

  # Do not add references if example_index is blank
  case $field_tag in (good|succeeded)
    [ -z "${field_pending:-}" ] && example_index=''
  esac

  case $field_tag in (skip|skipped)
    case ${SHELLSPEC_SKIP_MESSAGE:-} in (quiet)
      [ "${field_conditional:-}" ] && example_index=''
    esac
    case ${SHELLSPEC_SKIP_MESSAGE:-} in (moderate|quiet)
      eval "
        if [ \"\${field_specfile:-}\" != \"\$last_${field_tag}_specfile\" ]; then
          last_${field_tag}_specfile=''
        fi

        if [ \"\${field_skipid:-}\" = \"\$last_${field_tag}_id\" ]; then
          example_index=''
        fi
        last_${field_tag}_id=\${field_skipid:-}
      "
    esac
  esac

  if [ "$example_index" ]; then
    case $field_tag in (good|bad|warn|skip|pending)
      # Increment example_index if change example_no
      if [ "${field_specfile:-}" != "${last_example_specfile:-}" ]; then
        last_example_no=''
        last_example_specfile=$field_specfile
      fi
      if [ "$field_example_no" != "$last_example_no" ];then
        current_example_index=$(($current_example_index + 1))
        example_index=$current_example_index
        detail_index=0 last_example_no=$field_example_no
      fi
    esac
  fi

  if [ "$field_type" = "result" ]; then
    total_count=$(($total_count + 1))
    eval "${field_tag}_count=\$((\${${field_tag}_count:-0} + 1))"
    if [ "$field_tag" = "skipped" ] && [ -z "$example_index" ]; then
      suppressed_skipped_count=$((${suppressed_skipped_count:-0} + 1))
    fi
  fi

  [ "${field_error:-}" ] && exit_status=${SHELLSPEC_SPEC_FAILURE_CODE:-101}

  if [ "$fail_fast_count" ] ; then
    [ "${failed_count:-0}" -ge "$fail_fast_count" ] && fail_fast="yes"
  fi

  color_schema
  formatter_format "$@"
}
parse_lines each_line

if [ -z "$interrupt" ]; then
  if [ ! "$fail_fast" ]; then
    wait_for_log_exists "$SHELLSPEC_TIME_LOG" 30 ||:
  fi
  read_log "time" "$SHELLSPEC_TIME_LOG"
  read_log "trans" "$SHELLSPEC_TRANS_LOG"
fi

formatter_end

exit "$exit_status"
