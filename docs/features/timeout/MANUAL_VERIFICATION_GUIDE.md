# Manual Verification Guide for Timeout Feature

This guide provides step-by-step instructions to manually verify the timeout feature is working correctly.

---

## Quick Verification (5 minutes)

### Step 1: Check Help Text

```bash
./shellspec --help | grep -A 3 timeout
```

**Expected output:**
```
        --timeout SECONDS           Specify the default timeout for each test [default: 60]
                                      Format: NUMBER[s|m] (e.g., 30, 30s, 1m, 90s)
                                      Set to 0 to disable timeout
        --no-timeout                Disable timeout for all tests
```

✅ **Pass**: Timeout options appear in help
❌ **Fail**: No timeout options shown

---

### Step 2: Test Basic Functionality

Create a simple test file:

```bash
cat > /tmp/test_timeout.sh << 'EOF'
Describe 'Timeout test'
  It 'should pass quickly'
    When run echo "hello"
    The output should equal "hello"
  End
End
EOF
```

Run with timeout enabled:

```bash
./shellspec --timeout 5 --no-banner /tmp/test_timeout.sh
```

**Expected output:**
```
Running: /bin/sh [sh]
.

Finished in X.XX seconds
1 example, 0 failures
```

✅ **Pass**: Test runs and passes
❌ **Fail**: Error or test doesn't run

---

### Step 3: Test Timeout Format Validation

Try invalid format:

```bash
./shellspec --timeout abc 2>&1 | head -5
```

**Expected output:**
```
Invalid timeout format (use NUMBER[s|m], e.g., 30, 30s, 1m): --timeout
```

✅ **Pass**: Shows validation error
❌ **Fail**: No error or different error

---

## Comprehensive Testing (15-30 minutes)

### Test Case 1: Fast Completing Test

**Purpose**: Verify timeout doesn't interfere with normal tests

```bash
cat > /tmp/test_fast.sh << 'EOF'
Describe 'Fast tests'
  fast_function() {
    echo "completed"
  }

  It 'completes quickly'
    When call fast_function
    The output should equal "completed"
  End

  It 'also completes quickly'
    When call echo "fast"
    The output should equal "fast"
  End
End
EOF

./shellspec --timeout 10 --no-banner /tmp/test_fast.sh
```

**Expected result:**
```
..

Finished in X.XX seconds
2 examples, 0 failures
```

✅ **Pass**: Both tests pass, no timeout
❌ **Fail**: Tests fail or show timeout

---

### Test Case 2: Simulated Hang Test

**Purpose**: Verify timeout actually kills hung tests

```bash
cat > /tmp/test_hang.sh << 'EOF'
Describe 'Hang test'
  hang_function() {
    # Simulate a hang with a long loop
    i=0
    while [ $i -lt 999999999 ]; do
      i=$((i + 1))
    done
    echo "never reached"
  }

  It 'should timeout after 2 seconds' % timeout:2
    When call hang_function
    The output should equal "never reached"
  End
End
EOF

./shellspec --timeout 60 --no-banner /tmp/test_hang.sh 2>&1
```

**Expected result:**
```
F

Failures:

  1) Hang test should timeout after 2 seconds
     ...
     TIMEOUT
     Test exceeded timeout of 2 seconds
     ...

Finished in X.XX seconds
1 example, 1 failure
```

✅ **Pass**: Test shows TIMEOUT and is marked as failure
❌ **Fail**: Test hangs indefinitely or no timeout message

**Verification**:
- Test should complete in ~2 seconds (not hang)
- Output should show "TIMEOUT" message
- Exit code should indicate failure

---

### Test Case 3: Per-Test Timeout Override

**Purpose**: Verify per-test timeout metadata works

```bash
cat > /tmp/test_override.sh << 'EOF'
Describe 'Timeout override'
  fast_function() { echo "fast"; }

  It 'uses global timeout (60s)'
    When call fast_function
    The output should equal "fast"
  End

  It 'uses custom timeout (5s)' % timeout:5
    When call fast_function
    The output should equal "fast"
  End

  It 'uses another custom timeout (30s)' % timeout:30
    When call fast_function
    The output should equal "fast"
  End
End
EOF

./shellspec --timeout 60 --no-banner /tmp/test_override.sh
```

**Expected result:**
```
...

Finished in X.XX seconds
3 examples, 0 failures
```

✅ **Pass**: All tests pass with different timeouts
❌ **Fail**: Tests fail or errors occur

**How to verify override is working**:
```bash
# Run with translation to see generated code
./shellspec --translate /tmp/test_override.sh | grep -A 2 "SHELLSPEC_EXAMPLE_TIMEOUT"
```

Should show:
```
SHELLSPEC_EXAMPLE_TIMEOUT=''        # For first test (uses global)
SHELLSPEC_EXAMPLE_TIMEOUT='5'      # For second test
SHELLSPEC_EXAMPLE_TIMEOUT='30'     # For third test
```

---

### Test Case 4: Disable Timeout

**Purpose**: Verify `--no-timeout` works

```bash
cat > /tmp/test_no_timeout.sh << 'EOF'
Describe 'No timeout'
  slow_function() {
    # Takes about 2 seconds
    i=0
    while [ $i -lt 10000000 ]; do
      i=$((i + 1))
    done
    echo "completed"
  }

  It 'should complete without timeout'
    When call slow_function
    The output should equal "completed"
  End
End
EOF

# With --no-timeout, this should complete
./shellspec --no-timeout --no-banner /tmp/test_no_timeout.sh
```

**Expected result:**
```
.

Finished in X.XX seconds (may take a few seconds)
1 example, 0 failures
```

✅ **Pass**: Test completes successfully
❌ **Fail**: Test times out

Compare with timeout enabled (should timeout):
```bash
./shellspec --timeout 1 --no-banner /tmp/test_no_timeout.sh
```

Should show timeout failure.

---

### Test Case 5: Timeout Format Variations

**Purpose**: Verify different timeout formats work

```bash
# Test each format
for timeout in "30" "30s" "1m" "90s" "2m30s"; do
  echo "Testing format: $timeout"
  ./shellspec --timeout $timeout --version >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo "  ✅ $timeout - OK"
  else
    echo "  ❌ $timeout - FAILED"
  fi
done
```

**Expected output:**
```
Testing format: 30
  ✅ 30 - OK
Testing format: 30s
  ✅ 30s - OK
Testing format: 1m
  ✅ 1m - OK
Testing format: 90s
  ✅ 90s - OK
Testing format: 2m30s
  ✅ 2m30s - OK
```

---

### Test Case 6: Timeout with Hooks

**Purpose**: Verify timeout applies to entire test including hooks

```bash
cat > /tmp/test_hooks.sh << 'EOF'
Describe 'Timeout with hooks'
  slow_setup() {
    i=0
    while [ $i -lt 5000000 ]; do
      i=$((i + 1))
    done
  }

  BeforeEach 'slow_setup'

  It 'should timeout including hook time' % timeout:1
    When call echo "test"
    The output should equal "test"
  End
End
EOF

./shellspec --no-banner /tmp/test_hooks.sh 2>&1
```

**Expected result:**
```
F

Failures:

  1) Timeout with hooks should timeout including hook time
     ...
     TIMEOUT
     Test exceeded timeout of 1 seconds
     ...
```

✅ **Pass**: Test times out (BeforeEach + test > 1 second)
❌ **Fail**: Test completes successfully

---

## Debugging Tests

### Check Translation Output

See what code is generated:

```bash
./shellspec --translate /tmp/test_override.sh | less
```

Look for:
- `SHELLSPEC_EXAMPLE_TIMEOUT='X'` assignments
- `shellspec_parse_timeout` calls
- `SHELLSPEC_TIMEOUT_SIGNAL_FILE` usage

### Check Process Behavior

Monitor processes during test execution:

```bash
# In one terminal, run a test that will timeout
./shellspec --timeout 3 /tmp/test_hang.sh &

# In another terminal, watch processes
watch -n 0.5 'ps aux | grep -E "shellspec|watchdog|hang" | grep -v grep'
```

You should see:
1. Main shellspec process
2. Test process running
3. Watchdog process appear
4. After timeout: Watchdog kills test process
5. All processes cleaned up

### Verify File Cleanup

Check that temporary files are cleaned up:

```bash
# Run a test
./shellspec --timeout 5 /tmp/test_fast.sh

# Check for leftover timeout files
ls -la /tmp/shellspec.* 2>/dev/null | grep timeout
```

✅ **Pass**: No timeout signal/result files left behind
❌ **Fail**: Files remain after tests complete

---

## Advanced Verification

### Test with Parallel Execution

```bash
./shellspec --timeout 10 -j 4 --no-banner /tmp/test_fast.sh
```

**Expected**: Tests run in parallel without issues

### Test with Profiler

```bash
./shellspec --timeout 10 --profile --no-banner /tmp/test_fast.sh
```

**Expected**: Profiling works alongside timeout

### Test with Existing Test Suite

Run ShellSpec's own tests with timeout:

```bash
./shellspec --timeout 30 spec/general_spec.sh
```

**Expected**: All existing tests still pass

---

## Verification Checklist

Use this checklist to ensure all aspects work:

### Basic Functionality
- [ ] Help text shows timeout options
- [ ] `--timeout N` accepts numeric values
- [ ] `--timeout Ns` accepts seconds format
- [ ] `--timeout Nm` accepts minutes format
- [ ] `--no-timeout` disables timeout
- [ ] `--timeout 0` disables timeout
- [ ] Invalid formats show error message

### Timeout Behavior
- [ ] Fast tests complete normally with timeout enabled
- [ ] Slow tests timeout and are marked as FAILED
- [ ] Timeout message is clear and shows duration
- [ ] Tests are actually killed (don't hang forever)
- [ ] Cleanup happens (no orphaned processes/files)

### Per-Test Override
- [ ] `% timeout:N` syntax is recognized
- [ ] Per-test timeout overrides global timeout
- [ ] Translation shows correct SHELLSPEC_EXAMPLE_TIMEOUT value
- [ ] Multiple different timeouts in same file work

### Integration
- [ ] Works with parallel execution (`-j N`)
- [ ] Works with profiler (`--profile`)
- [ ] Works with different shells (`--shell bash/dash/zsh`)
- [ ] Works with existing test suites
- [ ] Doesn't break any existing features

### Edge Cases
- [ ] Timeout applies to BeforeEach/AfterEach hooks
- [ ] Very short timeout (1s) works
- [ ] Very long timeout (300s) works
- [ ] Multiple tests timeout in sequence
- [ ] Timeout with test that completes exactly at limit

---

## Expected Behavior Summary

| Scenario | Expected Result |
|----------|----------------|
| Fast test with timeout | ✅ Passes normally |
| Slow test exceeds timeout | ❌ Fails with TIMEOUT message |
| `--no-timeout` with slow test | ✅ Completes (takes time) |
| `% timeout:N` override | ✅ Uses N instead of global |
| Invalid format `--timeout abc` | ❌ Error message shown |
| Parallel execution | ✅ Works normally |
| With profiler | ✅ Both features work |

---

## Troubleshooting

### Issue: Tests hang forever

**Check**:
1. Is watchdog script executable? `ls -l libexec/shellspec-timeout-watchdog.sh`
2. Is watchdog being started? Add debug output
3. Are timeout files being created? Check `/tmp/shellspec.*`

**Fix**:
```bash
chmod +x libexec/shellspec-timeout-watchdog.sh
```

### Issue: All tests timeout immediately

**Check**:
1. Is timeout parser working? Test manually:
   ```bash
   . lib/libexec/timeout-parser.sh
   shellspec_parse_timeout "30"  # Should output: 30
   ```
2. Is SHELLSPEC_TIMEOUT set correctly? `echo $SHELLSPEC_TIMEOUT`

### Issue: Per-test timeout not working

**Check**:
```bash
./shellspec --translate /tmp/test_override.sh | grep SHELLSPEC_EXAMPLE_TIMEOUT
```

Should show different values for different tests.

### Issue: Timeout doesn't kill process

**Check**:
1. Is watchdog receiving correct PID?
2. Can watchdog send signals? Test:
   ```bash
   sleep 100 &
   PID=$!
   kill -TERM $PID  # Should work
   ```

---

## Quick Smoke Test (1 minute)

Run this one command to verify basic functionality:

```bash
echo 'Describe "Quick test"; It "works"; When call echo "ok"; The output should equal "ok"; End; End' | \
  ./shellspec --timeout 5 --no-banner -
```

**Expected**: Should show `1 example, 0 failures`

✅ **Pass**: Timeout feature is working
❌ **Fail**: Something is broken

---

## Clean Up

Remove test files after verification:

```bash
rm -f /tmp/test_*.sh
```

---

## Next Steps After Verification

Once verified:
1. ✅ Commit the changes
2. ✅ Update documentation
3. ✅ Run full test suite
4. ✅ Test on different shells
5. ✅ Create pull request (if applicable)
