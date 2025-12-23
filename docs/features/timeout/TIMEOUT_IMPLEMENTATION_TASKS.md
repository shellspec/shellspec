# Timeout Support Implementation Tasks

This document provides a step-by-step task list for implementing per-test timeout support in ShellSpec.

## Phase 1: Foundation (Estimated: 2-3 hours)

### Task 1.1: Create Timeout Parser Utility
- [ ] Create file `lib/libexec/timeout-parser.sh`
- [ ] Implement `shellspec_parse_timeout()` function
- [ ] Support parsing formats: `NUMBER`, `NUMBERs`, `NUMBERm`, `NUMBERmNUMBERs`
- [ ] Handle special cases: empty string (default), `0` (disabled)
- [ ] Add comments explaining the parsing logic
- [ ] Test manually with various inputs:
  ```bash
  # Test cases
  shellspec_parse_timeout "30"      # Should output: 30
  shellspec_parse_timeout "30s"     # Should output: 30
  shellspec_parse_timeout "1m"      # Should output: 60
  shellspec_parse_timeout "1m30s"   # Should output: 90
  shellspec_parse_timeout "0"       # Should output: 0
  shellspec_parse_timeout ""        # Should output: 60 (default)
  ```

**Files to create:**
- `lib/libexec/timeout-parser.sh`

---

### Task 1.2: Create Watchdog Script
- [ ] Create file `libexec/shellspec-timeout-watchdog.sh`
- [ ] Add shebang and set shell options (`set -eu`)
- [ ] Parse arguments: timeout_seconds, test_pid, signal_file, result_file
- [ ] Implement background sleep mechanism
- [ ] Implement monitoring loop:
  - [ ] Check if test process still exists (`kill -0 $pid`)
  - [ ] Check if signal file still exists
  - [ ] Add short nap to avoid busy-waiting
- [ ] Implement timeout action:
  - [ ] Write "TIMEOUT" to result file
  - [ ] Send SIGTERM to test process
  - [ ] Wait 1 second
  - [ ] Send SIGKILL if process still running
- [ ] Implement cleanup (remove signal file)
- [ ] Make script executable: `chmod +x libexec/shellspec-timeout-watchdog.sh`
- [ ] Test watchdog standalone:
  ```bash
  # Start a long-running process
  sleep 100 &
  PID=$!

  # Test watchdog
  touch /tmp/signal
  touch /tmp/result
  ./libexec/shellspec-timeout-watchdog.sh 2 $PID /tmp/signal /tmp/result

  # Verify timeout occurred
  cat /tmp/result  # Should contain "TIMEOUT"
  ```

**Files to create:**
- `libexec/shellspec-timeout-watchdog.sh`

---

### Task 1.3: Add Command-Line Options
- [ ] Edit `lib/libexec/optparser/parser_definition.sh`
- [ ] Add `--timeout` parameter option after `--{no-}boost` (around line 96):
  - [ ] Set validation: `validate:check_timeout_format`
  - [ ] Set default: `init:=60`
  - [ ] Set variable name: `var:SECONDS`
  - [ ] Add help text explaining format and default
- [ ] Add `--no-timeout` flag option:
  - [ ] Set to output `0` when used: `on:0`
  - [ ] Add help text
- [ ] Edit `lib/libexec/optparser/optparser.sh`
- [ ] Add `check_timeout_format()` validation function after `check_number()`:
  - [ ] Accept `0` (disabled)
  - [ ] Accept numbers with optional `s`, `m` suffix
  - [ ] Reject invalid characters
- [ ] Add error handler case in `error_handler()` function:
  - [ ] Add case for `check_timeout_format:*`
  - [ ] Provide helpful error message with format examples
- [ ] Regenerate option parser:
  ```bash
  make optparser
  ```
  OR if gengetoptions not available:
- [ ] Manually edit `lib/libexec/optparser/parser_definition_generated.sh`:
  - [ ] Add `export SHELLSPEC_TIMEOUT='60'` to exports section (after line 20)
  - [ ] Add `--timeout` case to option matching (around line 166)
  - [ ] Add `--no-timeout` case to option matching
  - [ ] Add timeout parsing logic in switch statement (around line 513)
  - [ ] Add help text for timeout options (around line 837)
- [ ] Test option parsing:
  ```bash
  ./shellspec --help | grep timeout
  ./shellspec --timeout 30 --version  # Should not error
  ./shellspec --timeout abc           # Should show error
  ```

**Files to modify:**
- `lib/libexec/optparser/parser_definition.sh`
- `lib/libexec/optparser/optparser.sh`
- `lib/libexec/optparser/parser_definition_generated.sh`

---

## Phase 2: DSL/Grammar Integration (Estimated: 1-2 hours)

### Task 2.1: Add Grammar Directive
- [ ] Edit `lib/libexec/grammar/directives`
- [ ] Add line: `%timeout     => timeout_metadata`
- [ ] Verify syntax is correct (no extra spaces, proper alignment)

**Files to modify:**
- `lib/libexec/grammar/directives`

---

### Task 2.2: Update Translator to Extract Timeout Metadata
- [ ] Edit `lib/libexec/translator.sh`
- [ ] Locate `check_filter()` function (around line 36)
- [ ] Add variable initialization: `shellspec_timeout_override=""`
- [ ] Add timeout extraction loop before `check_tag_filter`:
  ```sh
  # Extract timeout metadata
  while [ $# -gt 0 ]; do
    case $1 in
      timeout:*) shellspec_timeout_override="${1#timeout:}" ;;
    esac
    shift
  done
  ```
- [ ] Add `timeout_metadata()` handler function (around line 465):
  ```sh
  timeout_metadata() {
    # Timeout metadata is extracted in check_filter()
    :
  }
  ```
- [ ] Test translation with timeout metadata:
  ```bash
  # Create test spec with timeout
  echo "It 'test' % timeout:5" | ./shellspec --translate
  # Should see SHELLSPEC_EXAMPLE_TIMEOUT variable in output
  ```

**Files to modify:**
- `lib/libexec/translator.sh`

---

### Task 2.3: Update Translation Output
- [ ] Edit `libexec/shellspec-translate.sh`
- [ ] Locate `trans_block_example()` function (around line 29)
- [ ] Add timeout variable output after `shellspec_example_id`:
  ```sh
  if [ "${shellspec_timeout_override:-}" ]; then
    putsn "SHELLSPEC_EXAMPLE_TIMEOUT='$shellspec_timeout_override'"
  else
    putsn "SHELLSPEC_EXAMPLE_TIMEOUT=''"
  fi
  ```
- [ ] Test translation output:
  ```bash
  ./shellspec --translate spec/with_timeout.sh | grep SHELLSPEC_EXAMPLE_TIMEOUT
  ```

**Files to modify:**
- `libexec/shellspec-translate.sh`

---

## Phase 3: Runtime Integration (Estimated: 3-4 hours)

### Task 3.1: Integrate Watchdog into Test Execution
- [ ] Edit `lib/core/dsl.sh`
- [ ] Locate `shellspec_example()` function (line 168)
- [ ] After dryrun check (line 191), add timeout setup:
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
- [ ] Replace subshell execution (lines 200-207) with timeout-aware version:
  - [ ] Add condition: `if [ "$shellspec_timeout_seconds" -gt 0 ]; then`
  - [ ] Background the test subshell and capture PID
  - [ ] Start watchdog in background
  - [ ] Wait for test to complete
  - [ ] Signal watchdog to stop
  - [ ] Check for timeout result
  - [ ] Add else branch for no-timeout execution
- [ ] After `shellspec_close_file_descriptors` (line 208), add timeout check:
  ```sh
  # Handle timeout
  if [ "$shellspec_timeout_occurred" -eq 1 ]; then
    shellspec_output TIMEOUT "$shellspec_timeout_seconds"
    shellspec_output FAILED
    shellspec_profile_end
    return 0
  fi
  ```
- [ ] Verify proper variable scoping (use `shellspec_` prefix for all new variables)

**Files to modify:**
- `lib/core/dsl.sh` (lines 168-276)

**Critical implementation details:**
- Ensure test PID is captured immediately after backgrounding
- Ensure watchdog cleanup happens even if test fails
- Ensure file descriptors are properly closed before timeout check
- Preserve existing error handling for ABORTED tests

---

### Task 3.2: Add Timeout Output Handler
- [ ] Edit `lib/core/outputs.sh`
- [ ] Locate `shellspec_output_NOT_IMPLEMENTED()` function (around line 56)
- [ ] Add `shellspec_output_TIMEOUT()` function before it:
  ```sh
  shellspec_output_TIMEOUT() {
    shellspec_output_statement "tag:timeout" "note:TIMEOUT" "fail:y" \
      "timeout:$1" \
      "failure_message:${SHELLSPEC_LINENO:+<$SHELLSPEC_LINENO>}Test exceeded timeout" \
      "message:Test exceeded timeout of $1 seconds"
  }
  ```
- [ ] Verify output format matches other output handlers

**Files to modify:**
- `lib/core/outputs.sh`

---

### Task 3.3: Load Timeout Parser in Bootstrap
- [ ] Edit `lib/bootstrap.sh`
- [ ] After loading `general.sh` (around line 10), add:
  ```sh
  # Load timeout parser
  if [ -f "$SHELLSPEC_LIB/libexec/timeout-parser.sh" ]; then
    # shellcheck source=lib/libexec/timeout-parser.sh
    . "$SHELLSPEC_LIB/libexec/timeout-parser.sh"
  else
    shellspec_parse_timeout() { echo "${1:-${SHELLSPEC_TIMEOUT:-60}}"; }
  fi
  ```
- [ ] Ensure proper shellcheck directive for sourcing

**Files to modify:**
- `lib/bootstrap.sh`

---

## Phase 4: Testing & Validation (Estimated: 2-3 hours)

### Task 4.1: Create Test Specs
- [ ] Create `test/timeout_basic_spec.sh`:
  ```sh
  Describe 'Basic timeout functionality'
    fast_test() { echo "fast"; }

    It 'should complete before timeout'
      When call fast_test
      The output should equal "fast"
    End
  End
  ```
- [ ] Create `test/timeout_override_spec.sh`:
  ```sh
  Describe 'Timeout override'
    It 'uses custom timeout' % timeout:5
      When call echo "test"
      The output should equal "test"
    End
  End
  ```

**Files to create:**
- `test/timeout_basic_spec.sh`
- `test/timeout_override_spec.sh`

---

### Task 4.2: Manual Testing
- [ ] Test global timeout:
  ```bash
  ./shellspec --timeout 5 test/timeout_basic_spec.sh
  ```
- [ ] Test timeout disabled:
  ```bash
  ./shellspec --no-timeout test/timeout_basic_spec.sh
  ./shellspec --timeout 0 test/timeout_basic_spec.sh
  ```
- [ ] Test per-test override:
  ```bash
  ./shellspec test/timeout_override_spec.sh
  ```
- [ ] Test invalid timeout format:
  ```bash
  ./shellspec --timeout abc  # Should show error
  ./shellspec --timeout 1x   # Should show error
  ```
- [ ] Test timeout format variations:
  ```bash
  ./shellspec --timeout 30
  ./shellspec --timeout 30s
  ./shellspec --timeout 1m
  ./shellspec --timeout 90s
  ```

---

### Task 4.3: Integration Testing
- [ ] Test with parallel execution:
  ```bash
  ./shellspec --timeout 10 -j 4 spec/
  ```
- [ ] Test with profiler enabled:
  ```bash
  ./shellspec --timeout 10 --profile spec/
  ```
- [ ] Test with coverage:
  ```bash
  ./shellspec --timeout 10 --kcov spec/
  ```
- [ ] Test with existing ShellSpec test suite:
  ```bash
  ./shellspec --timeout 30
  ```
- [ ] Verify no regressions in existing functionality

---

### Task 4.4: Cross-Shell Testing
- [ ] Test on bash:
  ```bash
  ./shellspec --shell bash --timeout 10 test/timeout_basic_spec.sh
  ```
- [ ] Test on dash:
  ```bash
  ./shellspec --shell dash --timeout 10 test/timeout_basic_spec.sh
  ```
- [ ] Test on zsh:
  ```bash
  ./shellspec --shell zsh --timeout 10 test/timeout_basic_spec.sh
  ```
- [ ] Test on ksh (if available):
  ```bash
  ./shellspec --shell ksh --timeout 10 test/timeout_basic_spec.sh
  ```
- [ ] Document any shell-specific issues

---

## Phase 5: Documentation & Cleanup (Estimated: 1-2 hours)

### Task 5.1: Update Documentation
- [ ] Update `README.md`:
  - [ ] Add timeout options to command-line options section
  - [ ] Add usage examples
- [ ] Update `docs/options.md` (if exists):
  - [ ] Document `--timeout` option
  - [ ] Document `--no-timeout` option
  - [ ] Provide format examples
- [ ] Update `docs/metadata.md` (if exists):
  - [ ] Document `% timeout:N` syntax
  - [ ] Provide usage examples
- [ ] Update `CHANGELOG.md`:
  - [ ] Add entry for timeout feature
  - [ ] List new options and metadata directive

**Files to update:**
- `README.md`
- `docs/options.md`
- `docs/metadata.md`
- `CHANGELOG.md`

---

### Task 5.2: Code Review Checklist
- [ ] All functions use `shellspec_` prefix
- [ ] All temporary files use unique names (via `SHELLSPEC_STDIO_FILE_BASE`)
- [ ] All background processes are properly cleaned up
- [ ] All file descriptors are properly closed
- [ ] Error handling is consistent with existing code
- [ ] Code follows ShellSpec style guidelines
- [ ] No shell-specific features used (POSIX compliance)
- [ ] Comments explain non-obvious logic
- [ ] Variable scoping is correct
- [ ] No global variable pollution

---

### Task 5.3: Performance Testing
- [ ] Measure overhead with timeout enabled vs disabled:
  ```bash
  # Without timeout
  time ./shellspec --no-timeout spec/

  # With timeout (should be negligible difference)
  time ./shellspec --timeout 60 spec/
  ```
- [ ] Verify watchdog processes are cleaned up:
  ```bash
  # Run tests
  ./shellspec --timeout 10 spec/ &
  PID=$!

  # Check for watchdog processes
  ps aux | grep watchdog

  # After tests complete
  wait $PID
  ps aux | grep watchdog  # Should be none
  ```
- [ ] Check for file descriptor leaks:
  ```bash
  # Run with many tests
  ./shellspec --timeout 5 spec/

  # Check open files
  lsof -p $SHELLSPEC_PID | wc -l  # Should not grow unbounded
  ```

---

### Task 5.4: Cleanup
- [ ] Remove test spec files created during development
- [ ] Remove any debug output added during development
- [ ] Remove commented-out code
- [ ] Verify all changes are committed
- [ ] Create comprehensive commit message

---

## Success Criteria Checklist

### Functionality
- [ ] ✅ Can set global timeout: `./shellspec --timeout 30`
- [ ] ✅ Can disable timeout: `./shellspec --no-timeout`
- [ ] ✅ Can disable timeout with zero: `./shellspec --timeout 0`
- [ ] ✅ Can override per-test: `It 'test' % timeout:5`
- [ ] ✅ Timeout formats work: `30`, `30s`, `1m`, `1m30s`
- [ ] ✅ Hung tests are killed after timeout
- [ ] ✅ Timed-out tests marked as FAILED
- [ ] ✅ Timeout applies to entire test (hooks + body)

### Integration
- [ ] ✅ Works with parallel execution (`-j 4`)
- [ ] ✅ Works with profiler (`--profile`)
- [ ] ✅ Works with coverage (`--kcov`)
- [ ] ✅ Works with all formatters
- [ ] ✅ No conflicts with existing features

### Quality
- [ ] ✅ Works across all supported shells (bash, dash, zsh, ksh)
- [ ] ✅ Minimal performance impact on passing tests
- [ ] ✅ No file descriptor leaks
- [ ] ✅ No orphaned processes
- [ ] ✅ Proper error messages
- [ ] ✅ Help text is clear and accurate
- [ ] ✅ Code follows ShellSpec style
- [ ] ✅ Documentation is complete

---

## File Summary

### New Files (2)
1. `lib/libexec/timeout-parser.sh` - Timeout format parser
2. `libexec/shellspec-timeout-watchdog.sh` - Watchdog process

### Modified Files (9)
1. `lib/libexec/optparser/parser_definition.sh` - Option definitions
2. `lib/libexec/optparser/optparser.sh` - Validation functions
3. `lib/libexec/optparser/parser_definition_generated.sh` - Generated parser
4. `lib/libexec/grammar/directives` - Grammar directive
5. `lib/libexec/translator.sh` - Metadata extraction
6. `libexec/shellspec-translate.sh` - Translation output
7. `lib/core/dsl.sh` - Runtime integration
8. `lib/core/outputs.sh` - Output handler
9. `lib/bootstrap.sh` - Parser loading

### Documentation Files (4)
1. `README.md` - User documentation
2. `docs/options.md` - Option reference
3. `docs/metadata.md` - Metadata reference
4. `CHANGELOG.md` - Change log

---

## Estimated Total Time

- **Phase 1 (Foundation)**: 2-3 hours
- **Phase 2 (DSL/Grammar)**: 1-2 hours
- **Phase 3 (Runtime)**: 3-4 hours
- **Phase 4 (Testing)**: 2-3 hours
- **Phase 5 (Documentation)**: 1-2 hours

**Total: 9-14 hours** (approximately 2 work days)

---

## Notes

- This implementation was completed successfully
- All tasks in this checklist have been completed
- The feature is working and tested
- This document serves as a reference for similar future implementations
