# Per-Test Timeout Support Implementation Plan

## Overview

This document describes the implementation of per-test timeout support in ShellSpec to prevent hung tests and infinite loops.

## Requirements

Based on user input, the timeout feature must:

1. **Both global and per-test timeout**: Global `--timeout` sets default, individual tests can override
2. **Kill and mark as FAILED on timeout**: Tests that exceed timeout are terminated and marked as failures
3. **Timeout applies to entire test**: Includes BeforeEach hooks + test body + AfterEach hooks
4. **Reasonable default**: 60 second default timeout for all tests

## Architecture

### Timeout Mechanism: Background Watchdog Process

**Chosen Approach**: Background watchdog process (inspired by the existing profiler system)

**Why this approach:**
- **Cross-shell compatibility**: Works on all POSIX shells without relying on shell-specific features
- **Proven pattern**: The profiler already uses this approach successfully in ShellSpec
- **Hard enforcement**: Can forcefully kill hung tests
- **Minimal overhead**: Only one lightweight background process per test

**How it works:**
1. Before test execution, start a background watchdog process
2. Watchdog sleeps for the timeout duration
3. If watchdog wakes up and test is still running, kill the test process
4. If test completes before timeout, signal the watchdog to exit early
5. Use file-based signaling (like profiler) for inter-process communication

**Alternative approaches considered and rejected:**
- **Shell built-in timeout/SIGALRM**: Not portable across shells
- **External timeout command**: Not available on all systems, version differences
- **Polling loop**: CPU-intensive, less accurate

## Implementation Components

### 1. Command-Line Options

**File**: `lib/libexec/optparser/parser_definition.sh`

Added two new options:
```sh
param TIMEOUT --timeout validate:check_timeout_format init:=60 var:SECONDS
flag TIMEOUT --no-timeout on:0
```

**File**: `lib/libexec/optparser/optparser.sh`

Added validation function:
```sh
check_timeout_format() {
  case $OPTARG in
    0) return 0 ;;
    *[!0-9smSM]*) return 1 ;;
    *[0-9]|*[sSmM]) return 0 ;;
    *) return 1 ;;
  esac
}
```

**Environment variable created**: `SHELLSPEC_TIMEOUT` (default: 60)

### 2. Timeout Parser Utility

**New File**: `lib/libexec/timeout-parser.sh`

Parses timeout values from various formats to seconds:
- `30` → 30 seconds
- `30s` → 30 seconds
- `1m` → 60 seconds
- `1m30s` → 90 seconds

```sh
shellspec_parse_timeout() {
  # Parses timeout format and outputs seconds
  # Supports: NUMBER, NUMBERs, NUMBERm, NUMBERmNUMBERs
}
```

### 3. Watchdog Process

**New File**: `libexec/shellspec-timeout-watchdog.sh`

Background process that enforces timeout:

**Arguments:**
- `$1` = timeout_seconds
- `$2` = test_pid
- `$3` = signal_file (for early termination)
- `$4` = result_file (to indicate timeout occurred)

**Logic:**
1. Start background sleep for timeout duration
2. Loop while sleep is running:
   - Check if test process still exists
   - Check if signal file still exists (removed = test completed)
   - Short nap to avoid busy-waiting
3. If timeout expires and test still running:
   - Write "TIMEOUT" to result file
   - Send SIGTERM to test process
   - Wait 1 second
   - Send SIGKILL if still running
4. Clean up signal file

### 4. Grammar Support for Per-Test Timeout

**File**: `lib/libexec/grammar/directives`

Added directive:
```
%timeout     => timeout_metadata
```

**File**: `lib/libexec/translator.sh`

Modified `check_filter()` to extract timeout metadata:
```sh
check_filter() {
  shellspec_timeout_override=""
  # ... existing code ...

  # Extract timeout metadata
  while [ $# -gt 0 ]; do
    case $1 in
      timeout:*) shellspec_timeout_override="${1#timeout:}" ;;
    esac
    shift
  done

  check_tag_filter "$@"
}
```

Added handler function:
```sh
timeout_metadata() {
  # Timeout metadata is extracted in check_filter()
  :
}
```

### 5. Translation Layer

**File**: `libexec/shellspec-translate.sh`

Modified `trans_block_example()` to include timeout variable in generated code:
```sh
trans_block_example() {
  # ... existing code ...
  putsn "shellspec_example_id $block_id $example_no $block_no"

  if [ "${shellspec_timeout_override:-}" ]; then
    putsn "SHELLSPEC_EXAMPLE_TIMEOUT='$shellspec_timeout_override'"
  else
    putsn "SHELLSPEC_EXAMPLE_TIMEOUT=''"
  fi

  putsn "SHELLSPEC_LINENO_BEGIN=$lineno_begin"
  # ... rest of code ...
}
```

### 6. Runtime Integration

**File**: `lib/core/dsl.sh`

Modified `shellspec_example()` function to integrate watchdog:

**Before timeout setup (after dryrun check):**
```sh
# Timeout setup
SHELLSPEC_TIMEOUT_SIGNAL_FILE="$SHELLSPEC_STDIO_FILE_BASE.timeout_signal"
SHELLSPEC_TIMEOUT_RESULT_FILE="$SHELLSPEC_STDIO_FILE_BASE.timeout_result"
shellspec_effective_timeout="${SHELLSPEC_EXAMPLE_TIMEOUT:-${SHELLSPEC_TIMEOUT:-60}}"
shellspec_timeout_seconds=$(shellspec_parse_timeout "$shellspec_effective_timeout")

if [ "$shellspec_timeout_seconds" -gt 0 ]; then
  : > "$SHELLSPEC_TIMEOUT_SIGNAL_FILE"
  : > "$SHELLSPEC_TIMEOUT_RESULT_FILE"
fi
```

**Modified test execution:**
```sh
if [ "$shellspec_timeout_seconds" -gt 0 ]; then
  # Background the test subshell
  ( set -e; shellspec_invoke_example ) &
  shellspec_test_pid=$!

  # Start watchdog in background
  ( "$SHELLSPEC_SHELL" "$SHELLSPEC_LIBEXEC/shellspec-timeout-watchdog.sh" \
    "$shellspec_timeout_seconds" "$shellspec_test_pid" \
    "$SHELLSPEC_TIMEOUT_SIGNAL_FILE" "$SHELLSPEC_TIMEOUT_RESULT_FILE" \
  ) &

  # Wait for test to complete
  wait "$shellspec_test_pid"
  shellspec_exit_status=$?

  # Signal watchdog to stop
  rm -f "$SHELLSPEC_TIMEOUT_SIGNAL_FILE"

  # Check for timeout
  if [ -s "$SHELLSPEC_TIMEOUT_RESULT_FILE" ]; then
    shellspec_timeout_occurred=1
  else
    shellspec_timeout_occurred=0
  fi
  rm -f "$SHELLSPEC_TIMEOUT_RESULT_FILE"
else
  # No timeout - execute normally
  ( set -e; shellspec_invoke_example )
  shellspec_exit_status=$?
  shellspec_timeout_occurred=0
fi
```

**Timeout result handling:**
```sh
if [ "$shellspec_timeout_occurred" -eq 1 ]; then
  shellspec_output TIMEOUT "$shellspec_timeout_seconds"
  shellspec_output FAILED
  shellspec_profile_end
  return 0
fi
```

### 7. Output Handler

**File**: `lib/core/outputs.sh`

Added TIMEOUT output handler:
```sh
shellspec_output_TIMEOUT() {
  shellspec_output_statement "tag:timeout" "note:TIMEOUT" "fail:y" \
    "timeout:$1" \
    "failure_message:${SHELLSPEC_LINENO:+<$SHELLSPEC_LINENO>}Test exceeded timeout" \
    "message:Test exceeded timeout of $1 seconds"
}
```

### 8. Bootstrap Integration

**File**: `lib/bootstrap.sh`

Load timeout parser:
```sh
# Load timeout parser
if [ -f "$SHELLSPEC_LIB/libexec/timeout-parser.sh" ]; then
  . "$SHELLSPEC_LIB/libexec/timeout-parser.sh"
else
  shellspec_parse_timeout() { echo "${1:-${SHELLSPEC_TIMEOUT:-60}}"; }
fi
```

## Usage

### Global Timeout

```bash
# Set 30-second timeout for all tests
./shellspec --timeout 30

# Set 1-minute timeout
./shellspec --timeout 1m

# Set 90-second timeout
./shellspec --timeout 1m30s

# Disable timeout
./shellspec --no-timeout

# Or disable with 0
./shellspec --timeout 0
```

### Per-Test Timeout Override

```sh
Describe 'My tests'
  # This test gets 5 seconds
  It 'should complete quickly' % timeout:5
    When call some_function
    The output should equal "expected"
  End

  # This test gets 2 minutes
  It 'can take longer' % timeout:2m
    When call slow_function
    The status should equal 0
  End

  # This test uses global timeout (60s by default)
  It 'uses default timeout'
    When call another_function
    The output should equal "result"
  End
End
```

### Timeout with Hooks

The timeout applies to the entire test execution:
```sh
Describe 'Timeout with hooks'
  BeforeEach 'setup_function'  # Included in timeout

  It 'should timeout on entire test' % timeout:3
    When call test_function    # Included in timeout
    The status should equal 0
  End

  AfterEach 'cleanup_function'  # Included in timeout
End
```

If `setup_function` + `test_function` + `cleanup_function` takes more than 3 seconds total, the test times out.

## File Summary

### New Files
- `lib/libexec/timeout-parser.sh` - Parse timeout formats
- `libexec/shellspec-timeout-watchdog.sh` - Watchdog process

### Modified Files
- `lib/libexec/optparser/parser_definition.sh` - Add timeout options
- `lib/libexec/optparser/optparser.sh` - Add validation
- `lib/libexec/optparser/parser_definition_generated.sh` - Generated parser
- `lib/libexec/grammar/directives` - Add %timeout directive
- `lib/libexec/translator.sh` - Extract timeout metadata
- `libexec/shellspec-translate.sh` - Pass timeout to generated code
- `lib/core/dsl.sh` - Integrate watchdog (lines 168-276)
- `lib/core/outputs.sh` - Add TIMEOUT output handler
- `lib/bootstrap.sh` - Load timeout parser

## Design Decisions

### Why 60 seconds default?
- Reasonable for most tests
- Prevents truly hung tests from blocking forever
- Can be disabled with `--no-timeout` if needed

### Why file-based signaling?
- Cross-shell compatible
- Proven pattern in ShellSpec (profiler uses it)
- Simple and reliable
- No dependency on signal handling quirks

### Why kill entire test including hooks?
- Simpler implementation
- More predictable behavior
- Hooks can hang too
- Matches user expectation of "time limit for test"

### Why SIGTERM then SIGKILL?
- Give process chance to clean up (SIGTERM)
- Ensure termination if process ignores SIGTERM (SIGKILL)
- Standard Unix pattern

## Potential Issues & Solutions

### Issue: Watchdog becomes orphaned
**Solution**: File-based cleanup - watchdog exits when signal file is removed

### Issue: Race condition between test completion and timeout
**Solution**: Check process exists before killing, use atomic file operations

### Issue: Timeout during AfterEach cleanup
**Solution**: Expected behavior, document that timeout includes hooks

### Issue: Performance overhead
**Solution**: Minimal - watchdog just sleeps, only 1 per test

### Issue: Parallel execution conflicts
**Solution**: Each test uses unique files via `SHELLSPEC_STDIO_FILE_BASE`

## Testing Strategy

### Basic Functionality
```bash
# Test that timeout works
./shellspec --timeout 2 test_with_hang.sh

# Test that fast tests pass
./shellspec --timeout 60 test_fast.sh

# Test per-test override
./shellspec test_with_timeout_metadata.sh
```

### Edge Cases
- `--timeout 0` (disabled)
- `--no-timeout` (disabled)
- Very short timeout (1s)
- Very long timeout (300s)
- Timeout with parallel execution (`-j 4`)
- Timeout with profiler enabled (`--profile`)

### Cross-Shell Compatibility
Test on: bash, dash, zsh, ksh, busybox sh

## Success Criteria

✅ Can set global timeout: `./shellspec --timeout 30`
✅ Can disable timeout: `./shellspec --no-timeout`
✅ Can override per-test: `It 'test' % timeout:5`
✅ Hung tests are killed after timeout
✅ Timed-out tests marked as FAILED
✅ Works with parallel execution (`-j 4`)
✅ Works across all supported shells
✅ Minimal performance impact on passing tests

## Future Enhancements

Potential improvements for future versions:

1. **Custom timeout actions**: Allow custom handler instead of just killing
2. **Timeout warnings**: Warn at 80% of timeout threshold
3. **Group-level timeouts**: Apply timeout to entire Describe block
4. **Timeout reporting**: Show slowest tests approaching timeout
5. **Grace period**: Allow graceful shutdown before SIGKILL
6. **Timeout multiplier**: Scale all timeouts by a factor (for slow systems)
7. **Timeout per hook type**: Separate timeouts for BeforeEach vs test body vs AfterEach

## References

- ShellSpec profiler implementation (`libexec/shellspec-profiler.sh`)
- ShellSpec architecture documentation (`docs/architecture.md`)
- Test execution flow (`lib/core/dsl.sh`)
- Option parsing system (`lib/libexec/optparser/`)
