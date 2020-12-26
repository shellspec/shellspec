#!/bin/sh
#shellcheck disable=SC2004,SC2016

set -euf

interrupt=''
"$SHELLSPEC_TRAP" 'interrupt=1' INT
"$SHELLSPEC_TRAP" '' TERM

echo $$ > "$SHELLSPEC_REPORTER_PID"

# shellcheck source=lib/libexec/reporter.sh
. "${SHELLSPEC_LIB:-./lib}/libexec/reporter.sh"

import "formatter"
import "color_schema"
color_constants

found_focus='' no_examples='' aborted=1 repetition='' coverage_failed='' \
fail_fast='' fail_fast_count=${SHELLSPEC_FAIL_FAST_COUNT:-999999} reason='' \
current_example_index=0 example_index='' \
last_example_no='' last_skip_id='' not_enough_examples=''

# shellcheck disable=SC2034
specfile_count=0 expected_example_count=0 example_count=0 \
succeeded_count='' failed_count='' warned_count='' error_count='' \
todo_count='' fixed_count='' skipped_count='' error_index='' \
suppressed_todo_count='' suppressed_fixed_count='' suppressed_skipped_count=''

# shellcheck disable=SC2034
field_id='' field_type='' field_tag='' field_example_no='' field_focused='' \
field_temporary='' field_skipid='' field_pending='' field_message='' \
field_quick='' field_specfile='' field_stdout='' field_stderr=''

init_quick_data

[ "$SHELLSPEC_GENERATORS" ] && mkdir -p "$SHELLSPEC_REPORTDIR"

# shellcheck disable=SC2086
load_formatter "${SHELLSPEC_FORMATTER:-debug}" $SHELLSPEC_GENERATORS

formatters initialize "$@"
generators prepare "$@"
[ "$SHELLSPEC_XTRACE" ] && require_formatters trace

output_formatters begin

reporter_callback() {
  case $field_type in
    begin)
      field_example_count='' last_example_no=0 \
      last_skip_id='' suppress_pending=''
      inc specfile_count
      # shellcheck disable=SC2034
      example_count_per_file=0 succeeded_count_per_file=0 \
      failed_count_per_file=0 warned_count_per_file=0 todo_count_per_file=0 \
      fixed_count_per_file=0 skipped_count_per_file=0 error_count_per_file=0
      ;;
    example)
      # shellcheck disable=SC2034
      field_evaluation='' field_pending='' reason='' temporary_skip=0
      [ "$field_example_no" -le "$last_example_no" ] && repetition=1 && return 0
      [ "$field_focused" = "focus" ] && found_focus=1
      example_index='' last_example_no=$field_example_no
      ;;
    statement)
      while :; do
        # Do not add references if example_index is blank
        case $field_tag in
          evaluation) break ;;
          good)
            [ "$field_pending" ] || break
            [ ! "$suppress_pending" ] || break
            ;;
          bad) [ ! "$suppress_pending" ] || break ;;
          pending)
            suppress_pending=1
            case $SHELLSPEC_PENDING_MESSAGE in (quiet)
              [ "$field_temporary" ] || break
            esac
            suppress_pending=''
            ;;
          skip)
            case $SHELLSPEC_SKIP_MESSAGE in (quiet)
              [ "$field_temporary" ] || break
            esac
            case $SHELLSPEC_SKIP_MESSAGE in (moderate | quiet)
              [ ! "$field_skipid" = "$last_skip_id" ] || break
              last_skip_id=$field_skipid
            esac
            inc temporary_skip
        esac

        # shellcheck disable=SC2034
        case $field_tag in (pending | skip)
          reason=$field_message
        esac

        if [ ! "$example_index" ]; then
          inc current_example_index
          example_index=$current_example_index
        fi
        break
      done
      ;;
    result)
      inc example_count example_count_per_file
      inc "${field_tag}_count" "${field_tag}_count_per_file"
      [ "${failed_count:-0}" -ge "$fail_fast_count" ] && aborted='' fail_fast=1

      case $field_tag in (skipped | fixed | todo)
        [ "$example_index" ] || inc "suppressed_${field_tag}_count"
      esac

      add_quick_data "$field_specfile:@$field_id" "$field_tag" "$field_quick"
      ;;
    end)
      # field_example_count not provided when range or filter option specified
      field_example_count=${field_example_count:-$example_count_per_file}
      expected_example_count=$(($expected_example_count + $field_example_count))
      if [ "$example_count_per_file" -ne "$field_example_count" ]; then
        not_enough_examples=${not_enough_examples:-0}
        not_enough_examples=$(($not_enough_examples + $field_example_count))
        not_enough_examples=$(($not_enough_examples - $example_count_per_file))
      fi
      ;;
    error)
      inc error_count error_count_per_file
      base26 error_index "$error_count"
      ;;
    finished)
      aborted=''
      if [ "$SHELLSPEC_FAIL_NO_EXAMPLES" ]; then
        [ "$example_count" -gt 0 ] || no_examples=1
      fi
  esac

  color_schema
  output_formatters each "$@"

  [ ! "${fail_fast}${interrupt}${repetition}" ]
}

tssv_parse "field" reporter_callback ||:

timeout 1 read_time_log "time" "$SHELLSPEC_TIME_LOG" ||:
read_time_log "time" "$SHELLSPEC_TIME_LOG" ||:

output_formatters end

generators cleanup "$@"
formatters finalize "$@"

if [ "$repetition" ]; then
  error "Illegal executed same example" \
    "in ${field_specfile:-} line ${field_lineno_range:-}${LF}" \
    "(Use 'parameterized example' instead of running the example in a loop)$LF"
fi

if [ "${SHELLSPEC_FOCUS_FILTER:-}" ]; then
  if [ ! "$found_focus" ]; then
    notice "You specified --focus option, but not found any focused examples."
    notice "To focus, prepend 'f' to groups / examples. (e.g. fDescribe, fIt)$LF"
  fi
else
  if [ "$found_focus" ]; then
    notice "You need to specify --focus option" \
      "to run focused (underlined) example(s) only.$LF"
  fi
fi

if [ -e "$SHELLSPEC_QUICK_FILE" ] && [ ! "$interrupt" ]; then
  quick_file="$SHELLSPEC_QUICK_FILE" done=1
  [ "${aborted}${not_enough_examples}${fail_fast}" ] && done=''
  [ -e "$quick_file" ] && in_quick_file=$quick_file || in_quick_file=/dev/null
  quick_file_data=$(filter_quick_file "$done" "$@" < "$in_quick_file")
  if [ -s "$quick_file" ] && [ ! "$quick_file_data" ]; then
    notice "All examples have been passed. Rerun to prevent regression.$LF"
  fi
  puts "$quick_file_data${quick_file_data:+"$LF"}" | sort > "$quick_file"
fi

if [ -e "$SHELLSPEC_DEPRECATION_LOGFILE" ]; then
  count=0 found='Found '
  while IFS= read -r line && inc count; do
    [ "$SHELLSPEC_DEPRECATION_LOG" ] && notice "$line" 2>&1
  done < "$SHELLSPEC_DEPRECATION_LOGFILE"
  pluralize found "$count deprecation"
  if [ "$SHELLSPEC_DEPRECATION_LOG" ]; then
    notice "$found. Use --hide-deprecations to hide the details."
  else
    notice "$found. Use --show-deprecations to show the details."
  fi
fi

if [ "$repetition" ]; then
  exit_status=$SHELLSPEC_ERROR_EXIT_CODE
elif [ "$interrupt" ]; then
  exit_status=130
elif [ "$aborted" ]; then
  exit_status=1
elif [ "$SHELLSPEC_FAIL_LOW_COVERAGE" ] && [ "$coverage_failed" ]; then
  exit_status=$SHELLSPEC_FAILURE_EXIT_CODE
elif [ "$SHELLSPEC_WARNING_AS_FAILURE" ] && [ "$warned_count" ]; then
  exit_status=$SHELLSPEC_FAILURE_EXIT_CODE
elif [ "${failed_count}${error_count}${fixed_count}" ]; then
  exit_status=$SHELLSPEC_FAILURE_EXIT_CODE
elif [ "${not_enough_examples}${no_examples}" ]; then
  exit_status=$SHELLSPEC_FAILURE_EXIT_CODE
else
  exit_status=0
fi

exit "$exit_status"
