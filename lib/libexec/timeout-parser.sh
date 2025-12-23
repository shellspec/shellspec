#!/bin/sh
#shellcheck disable=SC2004

# Parse timeout format: 30, 30s, 1m, 1m30s → seconds
# Returns timeout in seconds
shellspec_parse_timeout() {
  timeout_value="$1"
  timeout_seconds=0

  # Handle special cases
  case $timeout_value in
    0) echo 0; return 0 ;;
    "") echo "${SHELLSPEC_TIMEOUT:-60}"; return 0 ;;
  esac

  # Parse minutes if present
  case $timeout_value in
    *[mM]*)
      timeout_minutes="${timeout_value%%[mM]*}"
      # Extract just the number before 'm'/'M'
      timeout_minutes="${timeout_minutes##*[^0-9]}"
      timeout_seconds=$((${timeout_minutes:-0} * 60))
      # Remove everything up to and including the 'm'/'M'
      timeout_value="${timeout_value#*[mM]}"
      ;;
  esac

  # Parse seconds if present
  case $timeout_value in
    *[sS]*) timeout_value="${timeout_value%%[sS]*}" ;;
  esac

  # Extract remaining number
  case $timeout_value in
    *[0-9]*)
      timeout_value="${timeout_value##*[^0-9]}"
      timeout_seconds=$((timeout_seconds + ${timeout_value:-0}))
      ;;
  esac

  echo "$timeout_seconds"
}
