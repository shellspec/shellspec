# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Added `be exported` and `be readonly` matchers.**
- Added `%printf` and `%sleep` directives.

### Changed

- **Improved TAP formatter.**
  - Supports `TODO` and `SKIP` directives.
  - Use `Bail out!` on error.
  - Added error details.
- `BeforeAll` / `AfterAll`: Avoid crashes due to hook errors.
- `Before` / `After`: Improved hook error handling.
- `BeforeCall` / `AfterCall`, `BeforeRun` / `AfterRun`: Minor changes.

### Removed

- Drop support for dash 0.5.3 due to unstable bug.

### Fixed

- Fixed a bug that "Parameter is not set" error in word modifier.
- Fixed a bug that satisfy matcher succeed even syntax error.
- Fixed a bug that can not CTRL-C with parallel execution on zsh.
- shellspec-syntax-check.sh: Some minor bug fixes.

## [0.26.1] - 2020-07-13

### Added

- **Added `--docker` option.** (EXPERIMENTAL)

## [0.26.0] - 2020-07-12

### Added

- **Added `Mock` helper (command-based mock).**
- **Added `%preserve` directive.**
- **Added `--sandbox`, `--sandbox-path` option.**
- Added `--path` option.

### Fixed

- Workaround when the Windows version of `sort.exe` is executed.

## [0.25.0] - 2020-06-21

### Added

- **Coverage support for zsh and ksh.** (#62)
- Respect `NO_COLOR` environment variable.
- Support [busybox-w32](https://frippery.org/busybox/) ash for windows.
- **Added `Assert` expectation to assert side effects of system environment.**
- Added `Dump` helper - dump stdout, stderr and status for debugging.
- Added `line` and `word` subject. (`of stdout (output)` can be omitted now)
- Added `--log-file` option to specify log file for `%logger` and trace.
- **Implement `--xtrace` (`--xtrace-only`) feature.**

### Changed

- Upgrade to alpine 3.12 for docker image and officially release `shellspec/kcov` docker image.
- Separate a file descriptor for reporting and stdout to able to use `echo` in specfile.
- Minor specification change of `result` modifier and `satisfy` matcher.
- `-r` option is now a short option for `--repair`, not `--require`.
- Use [debian/eol(https://hub.docker.com/r/debian/eol/) docker images for old debian tests.

### Fixed

- Before/After hooks should not consume stdin data (#82)

## [0.24.3] - 2020-06-06

### Fixed

- Fixes `BeforeAll` / `AfterAll` to share states

## [0.24.2] - 2020-05-27

### Fixed

- Fixed a bug "SHELLSPEC_GROUP_ID: unbound variable"
- Fixes when ran by "bash shellcpec" and "ksh shellspec"

## [0.24.1] - 2020-05-22

### Fixed

- Fixed broken `Todo`.
- Fixed a bug that caused an error when "--kcov" was specified and /dev/tty no be writable. (#67 Alexander Reitzel)
- Fixed a bug when enabled extendedglob for zsh.

## [0.24.0] - 2020-05-11

### Added

- Add `BeforeAll` and `AfterAll`. (#7)
- Expand parameter within Data helper. (#57)
- Add test for [GWSH shell](https://github.com/hvdijk/gwsh).
- Add manual test for OpenBSD ksh on OpenBSD 6.6.
- Add manual test for NetBSD sh on NetBSD 9.0.

### Removed

- Removed `match` matcher. Use `match pattern` matcher instead.
- Remove tests for unstable old shells (Bus Error, Bad address, Memory fault, etc).
  - CI test for pdksh 5.2.14 on FreeBSD.
  - Docker test for pdksh 5.2.14 on Debian 2.2r7.
  - Docker test for ksh 93q on Debian 3.1r8.
- Remove tests for FreeBSD 13.0-current (Unstable due to work in progress).

## [0.23.0] - 2020-04-02

### Added

- New **quick execution** and related options (`--quick`, `--repair`, `--next`).
- New **failures formatter**.
- Support **self-executable specfile**. (#40)
- Add `--pending-message` and `--quiet` option.
- Add short options for focus and filters.
- Add `-w` short options for `--warning-as-failure`.
- Add `--boost` (joke) option.
- Reporter: Displays comments of 'temporary skip' and 'temporary pending'.
- Support windows line endings. (#45)
- Syntax check for missing `End` of parameters.
- shellspec --init: generate ignore file for cvs.

### Changed

- Run the specfile specified by arguments even not end with `_spec.sh`.
- Formatter: Change fixed color.
- Formatter: Change mark for fixed and pending of progress formatter.

### Fixed

- Fixed `--pattern` option to avoid syntax error.
- Return exit status code on the specfile properly.
- Fixed a bug that `start with` and `end with` match glob pattern.
- Formatter: Fixed not display correctly of documentation formatter when description is empty.
- Fixed an issue installer.sh fails in some environments. (#43)

### Deprecated

- Use `--require` long option instead of `-r` short option.

## [0.22.0] - 2020-02-22

### Added

- Improve kcov version detection.
- Colored TAP formatter. (#34 Kylie McClain)
- Added `--show-deprecations` and  `--hide-deprecations` options.

### Changed

- New **kcov integration**.
  - Do not create translated specfile in project directory.
  - Suppress unnecessary coverage measurement to improve testing speed.
  - Added `--coverage-report-info` to add extra information to coverage report.
- make install compatible with BSD and macOS.
- Suppress unnecessary before/after hooks of skipped examples.
- install.sh: Install to under $HOME/.local by default
- Use $HOME/.config if not defined XDG_CONFIG_HOME

### Deprecated

- `--kcov-common-options` is deprecated, merge into `--kcov-options`.
- Deprecates the `match` matcher due to cause many syntax errors. Use `match pattern` matcher instead.

### Fixed

- Fixed broken test in docker on Linux.
- Fixed `--example` option to avoid syntax error.
- Append to LOGFILE instead of overwriting.

## [0.21.0] - 2020-01-30

### Added

- Provide **docker images**.
- Provide **distribution archive**.
- Available ArchLinux package. (#15 Damien Flament)

### Changed

- docs: Improve English quality. (#16 Damien Flament)

## [0.20.2] - 2019-08-24

### Fixed

- Fixed wrong SHELLSPEC_TMPBASE
- Fixed for bug that some shell can not call external command same name as builtin.

## [0.20.1] - 2019-08-19

### Fixed

- Fixed for solaris.

## [0.20.0] - 2019-08-18

### Added

- Add **parameterized example**. (`Parameters` helper)
- Add `Set` helper for set shell option
- Add `BeforeCall` / `AfterCall` helper.
- Add `BeforeRun` / `AfterRun` helper.
- Use `hexdump` if `od` does not exist.

### Changed

- Redesign `run` evaluation. [**major breaking change**]
  - Change the behavior to close to the `run` of bats.
  - New `run` evaluation allows the execution of functions and commands.
  - Use `run command` to execute only the commands. (old `run` -> use `run command`)
  - Merge `invoke` evaluation to `run` evaluation. (old `invoke` -> use `run`)
  - Merge `execute` evaluation to `run` evaluation. (old `execute` -> use `run source`)
- Export %const values to the translation process

### Removed

- Drop support for posh 0.10.2 and similar versions as the handling of the shell flag is broken.

### Fixed

- Fixed bug for related with tag.
- Fixed bug where coverage might not work on macOS.

## [0.19.1] - 2019-07-23

### Added

- Support install via make, bpkg, basher

## [0.19.0] - 2019-07-22

### Added

- Add installer (It has not been officially released, but you can used it already).
- Testing for **single script file** (Add `execute` evaluation, `Intercept` and `__SOURCED__` variable).
- Add `--keep-tempdir` option.
- Add `Data < <FILE>` syntax.

### Removed

- Drop support for busybox 1.1.3 and similar versions as it can not redefine builtin commands.
- Drop support for ash 0.3.8 and similar versions as it can not use retrun in sourced script.
- Remove `call`/`invoke` `<STRING>` syntax.

## [0.18.0] - 2019-07-09

### Added

- **Profiler feature** (`--profile`)
- Time attribute for JUnit XML.

## [0.17.0] - 2019-07-06

### Added

- **Coverage reporting**.
- Add `--fail-low-coverage` option.

## [0.16.0] - 2019-07-03

### Added

- **Coverage** support (kcov integration)
- Add **JUnit formatter** and **report generator**.
- Add `--warning-as-failure` option.
- Support [Unofficial Bash Strict Mode](http://redsymbol.net/articles/unofficial-bash-strict-mode/).
- Support for [Schily Bourne Shell](http://schilytools.sourceforge.net/bosh.html) (`bosh`, `pbosh`).

### Changed

- Change `--skip-message none` to `--skip-message verbose`.

### Removed

- Remove `--warnings` option.

## [0.15.0] - 2019-05-26

### Added

- Add `be empty directory` (alias: `be empty dir`) matcher.

### Changed

- Rename `be empty` matcher to `be empty file` matcher. [breaking change]

### Fixed

- Fixed bug that `be empty` (renamed to `be empty file`) matcher matches not exists file, etc.
- Ensure call & invoke start with errno zero (#2 Rowan Thorpe)

## [0.14.0] - 2019-05-15

### Added

- Add `--random` option.

### Changed

- Improve `--example`, `--tag` option.

## [0.13.1] - 2019-05-13

### Fixed

- Fixed bug when --dry-run mode.
- Fixed documentation formatter.

## [0.13.0] - 2019-05-12

### Added

- Add `--list examples:id` option.
- Add `*_spec.sh:@ID` syntax the specify id with the filename.
- Add `--pattern`, `--example`, `--tag`, `--default-path` filter option.

### Changed

- Change `Logger` Helper to `%logger` directive.
- Merge `--list-specfiles`, `--list-examples` options to `--list` option.
- Redesign reporter to improve performance, maintainability.

## [0.12.0] - 2019-04-26

### Added

- Add `--list-specfiles`, `--list-examples` option.
- Add `--env-from` option.
- Add tests that for array if supported shells.

### Changed

- Change `--count` option output includes the number of specfiles.
- Change to the banner show only on shellspec-runner.

## [0.11.3] - 2019-04-24

### Fixed

- Fixed broken parallel executor.

## [0.11.2] - 2019-04-23

### Fixed

- Fixed bug that does not work with zsh 5.4.2.

## [0.11.1] - 2019-04-21

### Fixed

- Fixed ignored specified line number when parallel execution.
- Fixed documentation formatter when supplied multiple specfiles.

## [0.11.0] - 2019-04-20

### Added

- Run **the example by line number**. (`*_spec.sh:#`)
- Run **focused groups / examples**. (`fDescribe`, `fContext`, `fExample`, `fSpecify`, `fIt`)
- Add `--count` option for count the number of examples without running.

## [0.10.0] - 2019-04-17

### Added

- Support **parallel execution**. (`--jobs` option)

### Changed

- Separete syntax checker into tools.
- Improve syntax checker.
- Improve error handling.
- Improve ctrl-c handling.

### Removed

- Remove `Def` helper. (use `%putsn`, `%puts` directive instead)

## [0.9.0] - 2019-03-30

### Added

- Add `--syntax-check` option for syntax check of the specfile.

### Changed

- Change timing of loading external script by 'Include'. [breaking change]

### Fixed

- Fix for translation speed slowdown.

### Removed

- Remove shorthand of the variable subject.

## [0.8.0] - 2019-03-26

### Added

- Add `Constant definition`.
- Add `Data` helper, `Embedded text`.
- Add `Def` helper.
- Add `Logger` helper.
- Add `result` modifier.
- Add `Include` helper.
- Add shorthand for `function` subject and `variable` subject.
- Add failed message for `Before`/`After` each hook.

### Changed

- Change behavior of `line` and `lines` modifier to like "grep -c" not "wc -l".
- Change `function` subject to alias for `value` subject.
- Improve handling unexpected errors.
- Improve samples.

### Removed

- Remove `It` statement and change `It` is alias of `Example` now.
- Remove `Set` / `Unset` helper.
- Remove `Debug` helper.
- Remove `string` subject.
- Remove `exit status` subject. (use `status` subject)

## [0.7.0] - 2019-03-08

### Added

- Added `lines` modifier.

## [0.6.0] - 2019-02-19

### Added

- Added `match` matcher.

## [0.5.0] - 2019-02-06

### Added

- Initial public release.

[Unreleased]: https://github.com/shellspec/shellspec/compare/0.26.1...HEAD
[0.26.1]: https://github.com/shellspec/shellspec/compare/0.26.0...0.26.1
[0.26.0]: https://github.com/shellspec/shellspec/compare/0.25.0...0.26.0
[0.25.0]: https://github.com/shellspec/shellspec/compare/0.24.3...0.25.0
[0.24.3]: https://github.com/shellspec/shellspec/compare/0.24.2...0.24.3
[0.24.2]: https://github.com/shellspec/shellspec/compare/0.24.1...0.24.2
[0.24.1]: https://github.com/shellspec/shellspec/compare/0.24.0...0.24.1
[0.24.0]: https://github.com/shellspec/shellspec/compare/0.23.0...0.24.0
[0.23.0]: https://github.com/shellspec/shellspec/compare/0.22.0...0.23.0
[0.22.0]: https://github.com/shellspec/shellspec/compare/0.21.0...0.22.0
[0.21.0]: https://github.com/shellspec/shellspec/compare/0.20.2...0.21.0
[0.20.2]: https://github.com/shellspec/shellspec/compare/0.20.1...0.20.2
[0.20.1]: https://github.com/shellspec/shellspec/compare/0.20.0...0.20.1
[0.20.0]: https://github.com/shellspec/shellspec/compare/0.19.0...0.20.0
[0.19.1]: https://github.com/shellspec/shellspec/compare/0.19.0...0.19.1
[0.19.0]: https://github.com/shellspec/shellspec/compare/0.18.0...0.19.0
[0.18.0]: https://github.com/shellspec/shellspec/compare/0.17.0...0.18.0
[0.17.0]: https://github.com/shellspec/shellspec/compare/0.16.0...0.17.0
[0.16.0]: https://github.com/shellspec/shellspec/compare/0.15.0...0.16.0
[0.15.0]: https://github.com/shellspec/shellspec/compare/0.14.0...0.15.0
[0.14.0]: https://github.com/shellspec/shellspec/compare/0.13.1...0.14.0
[0.13.1]: https://github.com/shellspec/shellspec/compare/0.13.0...0.13.1
[0.13.0]: https://github.com/shellspec/shellspec/compare/0.12.0...0.13.0
[0.12.0]: https://github.com/shellspec/shellspec/compare/0.11.3...0.12.0
[0.11.3]: https://github.com/shellspec/shellspec/compare/0.11.2...0.11.3
[0.11.2]: https://github.com/shellspec/shellspec/compare/0.11.1...0.11.2
[0.11.1]: https://github.com/shellspec/shellspec/compare/0.11.0...0.11.1
[0.11.0]: https://github.com/shellspec/shellspec/compare/0.10.0...0.11.0
[0.10.0]: https://github.com/shellspec/shellspec/compare/0.9.0...0.10.0
[0.9.0]: https://github.com/shellspec/shellspec/compare/0.8.0...0.9.0
[0.8.0]: https://github.com/shellspec/shellspec/compare/0.7.0...0.8.0
[0.7.0]: https://github.com/shellspec/shellspec/compare/0.6.0...0.7.0
[0.6.0]: https://github.com/shellspec/shellspec/compare/0.5.0...0.6.0
[0.5.0]: https://github.com/shellspec/shellspec/commits/0.5.0
