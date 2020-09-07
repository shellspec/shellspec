# Project directory structure

- [`.shellspec` / `.shellspec-local` - configure default options](#shellspec--shellspec-local---configure-default-options)
- [`.shellspec-quick.log` - log file for quick execution](#shellspec-quicklog---log-file-for-quick-execution)
- [`report/` - output directory of report file](#report---output-directory-of-report-file)
- [`coverage/` - output directory of coverage reports](#coverage---output-directory-of-coverage-reports)
- [`spec/` - default specfiles directory](#spec---default-specfiles-directory)
- [`spec/banner` - banner file displayed at test execution](#specbanner---banner-file-displayed-at-test-execution)
- [`spec/spec_helper.sh` - default helper file for specfile](#specspec_helpersh---default-helper-file-for-specfile)
- [`spec/support/` - directory for support files](#specsupport---directory-for-support-files)
- [`spec/support/bin` - directory for support commands](#specsupportbin---directory-for-support-commands)

## `.shellspec` / `.shellspec-local` - configure default options

To change the default options for the `shellspec` command, create options file(s).
Files are read in the order shown below, options defined last take precedence.

1. `$XDG_CONFIG_HOME/shellspec/options`
2. `$HOME/.shellspec`
3. `./.shellspec`
4. `./.shellspec-local` (Do not store in VCS such as git)

Specify your default options with `$XDG_CONFIG_HOME/shellspec/options` or `$HOME/.shellspec`.
Specify default project options with `.shellspec` and overwrite to your favorites with `.shellspec-local`.

## `.shellspec-quick.log` - log file for quick execution

Log file used for Quick execution.

## `report/` - output directory of report file

Directory for report output using the `--output` option.

## `coverage/` - output directory of coverage reports

Directory where kcov outputs coverage reports.

## `spec/` - default specfiles directory

Directory where you create specfiles.

## `spec/banner` - banner file displayed at test execution

If `spec/banner` file exists, the banner is shown when the `shellspec` command
is executed. Disable that behavior with the `--no-banner` option.

## `spec/spec_helper.sh` - default helper file for specfile

The `spec_helper.sh` is loaded to specfile by the `--require spec_helper` option.
This file is used to define global functions, initial setting for examples, custom matchers, etc.

## `spec/support/` - directory for support files

This directory is used to store files for custom matchers, tasks, etc.

## `spec/support/bin` - directory for support commands

This directory is used to store [support commands](#support-commands).
