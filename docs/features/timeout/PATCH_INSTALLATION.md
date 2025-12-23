# How to Manually Apply the Timeout Feature

If you need to use the timeout feature before the official release (v0.29.0) is merged, you can apply it as a patch to your existing ShellSpec installation.

## Prerequisites

- `curl` or `wget`
- `patch` utility (standard on most Unix-like systems)
- Access to your ShellSpec installation directory

## Quick Installation

### Step 1: Navigate to Your ShellSpec Installation

```bash
# Common locations:
cd ~/.local/lib/shellspec          # If installed via installer
# OR
cd /path/to/your/shellspec         # If cloned/extracted manually
```

### Step 2: Download the Patch

```bash
curl -L https://raw.githubusercontent.com/OleksandrKucherenko/shellspec/timeout-implementation/docs/features/timeout/shellspec-0.28.1-to-0.29.0-timeout.patch -o timeout.patch
```

### Step 3: Apply the Patch

```bash
patch -p1 < timeout.patch
```

You will see output like:
```
patching file lib/bootstrap.sh
patching file lib/core/dsl.sh
patching file lib/core/outputs.sh
...
patching file shellspec
Hunk #1 FAILED at 5.
1 out of X hunks FAILED -- saving rejects to file bin/shellspec.rej
```

**⚠️ Note:** The `bin/shellspec.rej` rejection is **harmless and expected**. See explanation below.

### Step 4: Verify the Installation

```bash
# Check version
./shellspec --version
# Expected: 0.29.0-dev

# Check timeout options
./shellspec --help | grep timeout
# Expected:
#   --timeout SECONDS           Specify the default timeout for each test [default: 60]
#   --no-timeout                Disable timeout for all tests
```

### Step 5: (Optional) Clean Up

```bash
# Remove the rejection file (it's harmless)
rm -f bin/shellspec.rej

# Remove the patch file
rm timeout.patch
```

## Why `bin/shellspec.rej` is Harmless

In ShellSpec, `bin/shellspec` is a **symlink** pointing to the main `shellspec` file:

```
bin/shellspec -> ../shellspec
```

When the patch is applied:
1. The main `shellspec` file is patched correctly ✅
2. The patch tool then tries to patch `bin/shellspec` (the symlink)
3. This fails because it's patching the same content twice
4. But since the main file is already correct, **nothing is missing**

You can verify this:
```bash
ls -la bin/shellspec
# Shows: bin/shellspec -> ../shellspec
```

## Using the Timeout Feature

Once installed, you can use timeout like this:

```bash
# Set global timeout (30 seconds for all tests)
./shellspec --timeout 30

# Disable timeout
./shellspec --no-timeout

# Use per-test timeout in your spec files
It 'should complete quickly' % timeout:5
  When call my_function
  The status should equal 0
End
```

## Rolling Back

To revert all changes:

```bash
patch -R -p1 < timeout.patch
rm timeout.patch
rm -f bin/shellspec.rej
```

## Troubleshooting

### Tests hang instead of timing out

Check if the watchdog has the PATH fix:
```bash
head -15 libexec/shellspec-timeout-watchdog.sh
```

You should see:
```sh
if [ "${SHELLSPEC_PATH:-}" ]; then
  PATH="$SHELLSPEC_PATH"
  export PATH
fi
```

### "rm: command not found" or "sleep: command not found"

This means the PATH fix wasn't applied. Verify the watchdog file as shown above.

### Other rejections besides bin/shellspec.rej

If you see other `.rej` files, you may be patching a different version than 0.28.1.
Check for rejections:
```bash
find . -name "*.rej"
```

For critical rejections in `lib/core/dsl.sh` or `lib/core/outputs.sh`, see the manual fix instructions at the end of this document.

## Manual Fixes (If Needed)

### lib/core/outputs.sh

If rejected, add this function after `shellspec_output_NOT_IMPLEMENTED`:

```sh
shellspec_output_TIMEOUT() {
  shellspec_output_statement "tag:timeout" "note:TIMEOUT" "fail:y" \
    "timeout:$1" \
    "failure_message:${SHELLSPEC_LINENO:+<$SHELLSPEC_LINENO>}Test exceeded timeout" \
    "message:Test exceeded timeout of $1 seconds"
}
```

### lib/core/dsl.sh

If rejected, the timeout execution logic needs to be added to the `shellspec_example` function.
Key point: Use `shellspec_rm -f` instead of `rm -f` for timeout file cleanup.
