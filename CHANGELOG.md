# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.16.0] - 2019-07-03

### Added

- Coverage support (kcov integration)
- Add JUnit formatter and report generator.
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

- Run the example by line number. (`*_spec.sh:#`)
- Run focused groups / examples. (`fDescribe`, `fContext`, `fExample`, `fSpecify`, `fIt`)
- Add `--count` option for count the number of examples without running.

## [0.10.0] - 2019-04-17

### Added

- Support parallel execution. (`--jobs` option)

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

[Unreleased]: https://github.com/shellspec/shellspec/compare/0.16.0...HEAD
[0.15.0]: https://github.com/shellspec/shellspec/compare/0.15.0...0.16.0
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
