#!/bin/sh
#shellcheck disable=SC2016,SC2004

set -eu

# Timeout watchdog process
# Arguments:
#   $1 = timeout_seconds
#   $2 = test_pid
#   $3 = signal_file
#   $4 = result_file

timeout_seconds="$1"
test_pid="$2"
signal_file="$3"
result_file="$4"

# Start sleep for the timeout duration in background
sleep "$timeout_seconds" &
sleep_pid=$!

# Wait for either timeout or early termination signal
while kill -0 "$sleep_pid" 2>/dev/null; do
  # Check if test process is still running
  if ! kill -0 "$test_pid" 2>/dev/null; then
    # Test completed before timeout
    kill "$sleep_pid" 2>/dev/null || :
    exit 0
  fi

  # Check for early termination signal (signal file removed)
  if [ ! -e "$signal_file" ]; then
    # Test completed, signal received
    kill "$sleep_pid" 2>/dev/null || :
    exit 0
  fi

  # Short nap to avoid busy-waiting
  # Try fractional sleep first, fall back to 1s
  sleep 0.1 2>/dev/null || sleep 1
done

# Timeout occurred - kill the test process
if kill -0 "$test_pid" 2>/dev/null; then
  # Write timeout marker to result file
  echo "TIMEOUT" > "$result_file"

  # Kill test process tree
  # First try graceful TERM, then forceful KILL
  kill -TERM "$test_pid" 2>/dev/null || :
  sleep 1
  kill -KILL "$test_pid" 2>/dev/null || :
fi

# Cleanup signal file
rm -f "$signal_file" || :
