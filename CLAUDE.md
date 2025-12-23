# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

ShellSpec is a full-featured BDD unit testing framework for POSIX shells (dash, bash, ksh, zsh, etc.). It provides code coverage, mocking, parameterized tests, parallel execution, and more. The framework is designed to work across multiple shell implementations and platforms.

## Development Commands

### Running Tests

```bash
# Run all tests
./shellspec

# Run tests on a specific file/directory
./shellspec spec/general_spec.sh
./shellspec spec/core/

# Run a specific example by line number
./shellspec spec/general_spec.sh:42

# Run with coverage (requires kcov)
./shellspec --kcov

# Quick mode (re-run only failed tests)
./shellspec --quick

# Run tests in parallel
./shellspec --jobs 4

# Syntax check specfiles without running
./shellspec --syntax-check

# Show translated specfile (see what the DSL becomes)
./shellspec --translate spec/general_spec.sh
```

### Testing on Multiple Shells

```bash
# Test on all installed shells
contrib/all.sh

# Test in Docker containers with various shells
contrib/test_in_docker.sh dockerfiles/debian.Dockerfile

# Check syntax across the entire project (requires Docker)
contrib/check.sh
```

### Development Tools

```bash
# Initialize a new project
./shellspec --init

# Generate support commands (test helpers)
./shellspec --gen-bin @touch @sed

# Count specfiles and examples
./shellspec --count

# List all specfiles
./shellspec --list specfiles

# List all examples
./shellspec --list examples
```

## Architecture

ShellSpec follows a multi-stage execution model:

1. **shellspec** (main executable) - Parses command-line options
2. **shellspec-runner.sh** - Orchestrates executor and reporter
3. **shellspec-executor.sh** - Manages translation and execution
4. **shellspec-translate.sh** - Translates specfiles from DSL to plain shell script
5. **shellspec-reporter.sh** - Formats and outputs test results

### Key Architectural Principles

- **Translation Process**: Specfiles are NOT executed directly. They are first translated from DSL syntax to regular shell scripts with ShellSpec core libraries included, then executed in a separate process.
- **Scope via Subshells**: Each example group and example block runs in a subshell, providing isolated scopes for variables and functions.
- **Performance Focus**: Core scripts avoid external commands, subshells, pipes, and command substitution as much as possible for performance and portability.
- **Shell Independence**: The framework is designed to work identically across POSIX-compliant shells.

### Directory Structure

```
shellspec              # Main executable entry point
libexec/               # Executable components (runner, executor, translator, reporter)
lib/                   # Core libraries
  ├── core/            # Core DSL implementation (subjects, modifiers, matchers)
  ├── libexec/         # Library support for executables
  └── general.sh       # General utility functions
spec/                  # Test specs for ShellSpec itself
helper/                # Helper files for ShellSpec's own tests
  └── spec_helper.sh   # Test helper configuration
examples/              # Example specfiles demonstrating features
contrib/               # Development and testing utilities
```

## Code Organization

### Core Components (lib/core/)

- **matchers.sh** - Verification matchers (eq, match, include, etc.)
- **subjects.sh** - Subjects for verification (output, status, variable, etc.)
- **syntax.sh** - DSL syntax definitions
- **statement.sh** - Core statement implementations
- **utils.sh** - Utility functions for core operations
- **verb.sh** - Verb implementations (should, should not)

### Translation System (lib/libexec/)

- **translator.sh** - Main translation logic
- **grammar.sh** - DSL grammar definitions
- **executor.sh** - Test execution management
- **reporter.sh** - Test reporting and formatting

### Execution Modes

- **Serial Execution** - Tests run sequentially (default)
- **Parallel Execution** - Tests run in parallel (`--jobs N`)
- **Coverage Mode** - Integrated with kcov for code coverage (`--kcov`)

## DSL Translation

Specfiles use a DSL that gets translated to shell script:

```bash
Describe 'example'      # → function block in subshell
  It 'does something'   # → function block in subshell
    When call func      # → execute and capture output/status
    The output should eq "expected"  # → verification
  End
End
```

Use `./shellspec --translate <specfile>` to see the generated code.

## Testing Patterns

### Function-Based vs Command-Based Mocks

- **Function-based mocks**: Fast, defined as shell functions in the specfile
- **Command-based mocks**: Create temporary shell scripts, can mock external commands with invalid function names (e.g., `docker-compose`)

### When to Use Each Evaluation Type

- `When call` - Call shell functions without subshell
- `When run` - Run commands in subshell (most common for commands)
- `When run script` - Run shell script ignoring shebang
- `When run source` - Source script (enables function mocking)

### Coverage Measurement

Coverage only works on:
- Shell scripts loaded by `Include`
- Functions called by `When call`
- Scripts executed by `When run script` or `When run source`

Coverage does NOT work on:
- External commands (even if shell scripts)
- Scripts executed normally via shebang

## Important Constraints

### Code Style Requirements

- **POSIX Compliance**: All code must work across POSIX shells
- **Performance Critical**: Avoid external commands in hot paths
- **No Advanced Features**: Cannot rely on bash/zsh-specific features unless guarded
- **Portability**: Support shells from bash 2.03+, dash 0.5.4+, zsh 3.1.9+, ksh 93r+

### External Command Restrictions

Core scripts (lib/, libexec/) minimize external command usage:
- Allowed: `cat`, `date`, `env`, `ls`, `mkdir`, `od`, `rm`, `sleep`, `sort`, `time`, `printf`, `kill`
- Avoid in hot paths: Any external command that can be done with shell built-ins

### Shell Compatibility

The codebase handles many shell-specific bugs and quirks. Check:
- `SHELLSPEC_DEFECT_*` variables for known shell bugs
- `helper/ksh_workaround.sh` for shell-specific workarounds
- Variable exports and readonly handling vary significantly by shell

## Project-Specific Options

ShellSpec uses itself for testing. Default options in `.shellspec`:
- `--require spec_helper` - Load helper configuration
- `--sandbox` - Force command mocking (security feature for tests)
- `--helperdir helper` - Use `helper/` instead of `spec/` for helpers
- `--skip-message moderate` - Reduce skip message verbosity
- `--fail-no-examples` - Fail if no examples found

## References

- **README.md** - Comprehensive user documentation
- **docs/architecture.md** - Architecture overview
- **docs/references.md** - Complete DSL reference
- **CONTRIBUTING.md** - Developer contribution guide
- **examples/spec/** - Working examples of all features
