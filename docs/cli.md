# ShellSpec CLI

- [Initialize your project (`--init`)](#initialize-your-project---init)
- [Specify the shell to run (`--shell`)](#specify-the-shell-to-run---shell)
- [Quick execution (`--quick`, `--repair`, `--next`)](#quick-execution---quick---repair---next)
- [Parallel execution (`--jobs`)](#parallel-execution---jobs)
- [Random execution (`--random`)](#random-execution---random)
- [Fail fast (`--fail-fast`)](#fail-fast---fail-fast)
- [Trace (`--xtrace`, `--xtrace-only`)](#trace---xtrace---xtrace-only)
- [Sandbox mode (`--sandbox`)](#sandbox-mode---sandbox)
- [Ranges (`:LINENO`, `:@ID`) / Filters (`--example`) / Focus (`--focus`)](#ranges-lineno-id--filters---example--focus---focus)
- [Reporter (`--format`) / Generator (`--output`)](#reporter---format--generator---output)
- [Profiler (`--profile`)](#profiler---profile)
- [Run tests in Docker container (`--docker`)](#run-tests-in-docker-container---docker)
- [Task runner (`--task`)](#task-runner---task)

## Initialize your project (`--init`)

Run `shellspec --init` initializes the current directory for ShellSpec.
It creates `.shellspec` and `spec/spec_helper.sh`

## Specify the shell to run (`--shell`)

Specify the shell to run with `--shell` option.
ShellSpec ignores shebang and runs the shell script in the specified shell.
The default is the shell running the `shellspec` command (usually `/bin/sh`).

## Quick execution (`--quick`, `--repair`, `--next`)

Quick execution is a feature for rapid development and failure fixing.

When you run `shellspec` with `--quick` option first, Quick mode is automatically enabled.
When Quick mode enabled, The file `.shellspec-quick.log` generated on the project root directory.
If you want to disable Quick mode, delete `.shellspec-quick.log`.

When Quick mode enabled, the results of running examples are logged to `.shellspec-quick.log`
on the project root directory (even if `--quick` option is not specified).

Use `--quick` option is for rapid development. When `--quick` option specified, It runs examples
that not-passed (failure and temporary pending) the last time they ran.
If there are no examples that did not pass, It runs all examples.
It is designed to be added to `$HOME/.shellspec` instead of being specified each runs.

Use `--repair` and `--next` option is for rapid failure fixing.
It runs failed examples only (not includes temporary pending).

## Parallel execution (`--jobs`)

You can use parallel execution for fast test with `--jobs` option. Parallel
jobs are executed per specfile. So it is necessary to separate the specfile
for effective parallel execution.

## Random execution (`--random`)

You can randomize the execution order to detect troubles due to the test
execution order. If `SEED` is specified, the execution order is deterministic.

## Fail fast (`--fail-fast`)

You can stop on the first (N times) failures with `--fail-fast` option.

NOTE: The reporter that count the number of failures and specfile execution are processed in parallel.
Therefore, the specfile execution may precede the location where it stopped due to a failure.

## Trace (`--xtrace`, `--xtrace-only`)

You can trace evaluation with `--xtrace` or `--xtrace-only` option.

If `BASH_XTRACEFD` is implemented in the shell, you can run tests and traces at the same time.
Otherwise, run tracing only. The output format can be set with the variable `PS4`.

NOTE: `BASH_XTRACEFD` only available *bash version >= 4.1* or *busybox (ash) version >= 1.28.0*.

## Sandbox mode (`--sandbox`)

Force the use of the mock instead of the actual command.
This option makes the `PATH` environment variable empty (except `spec/support/bin`) and `readonly`.

[Support commands](#support-commands) help to call the actual command in sandbox mode.

NOTE: This is not a security feature and does not provide complete isolation.
For example, if specified with an absolute path, the actual command will be executed.
If you need strict isolation, use Docker or similar technology.

## Ranges (`:LINENO`, `:@ID`) / Filters (`--example`) / Focus (`--focus`)

You can run specific example(s) or example group(s) only.

It can be specified by line number (`a_spec.sh:10:20`), example id (`a_spec.sh:@1-5:@1-6`),
example name (`--example` option), tag (`--tag` option) and focus (`--focus` option).

To focus, prepend `f` to groups / examples in specfiles (e.g. `Describe` -> `fDescribe`, `It` -> `fIt`)
and run with `--focus` option.

## Reporter (`--format`) / Generator (`--output`)

You can specify one reporter (output to stdout) and multiple generators
(output to a file). Currently builtin formatters are `progress`,
`documentation`, `tap`, `junit`, `failures`, `null`, `debug`.

NOTE: Custom formatter is supported (but not documented yet, sorry).

## Profiler (`--profile`)

When the `--profile` option is specified, the profiler is enabled and lists the slow examples.

## Run tests in Docker container (`--docker`)

**NOTE: This is an experimental feature and may be changed/removed in the future.**

When the `--docker DOCKER-IMAGE` option is specified, run tests using the specified Docker image.

If you specify only the tag that starts with `:` as DOCKER-IMAGE (e.g. `--docker :debian10`),
Use ShellSpec official runtime image (`shellspec/runtime`).
The ShellSpec official runtime image contains supported shells.

See available tags: https://hub.docker.com/r/shellspec/runtime/tags

## Task runner (`--task`)

You can run the task with `--task` option.
