# ShellSpec

BDD style unit testing framework for POSIX compliant shell script.

**Let’s test your shell script!** (Try the **[Online Demo](https://shellspec.info/demo)** on the browser).

[![demo](docs/demo.gif)](https://shellspec.info/demo)

[![Travis CI](https://img.shields.io/travis/com/shellspec/shellspec/master.svg?label=TravisCI&style=flat-square)](https://travis-ci.com/shellspec/shellspec)
[![Cirrus CI](https://img.shields.io/cirrus/github/shellspec/shellspec.svg?label=CirrusCI&style=flat-square)](https://cirrus-ci.com/github/shellspec/shellspec)
[![Circle CI](https://img.shields.io/circleci/build/github/shellspec/shellspec.svg?label=CircleCI&style=flat-square)](https://circleci.com/gh/shellspec/shellspec)
[![GitHub Actions Status](https://img.shields.io/github/workflow/status/shellspec/shellspec/Release?label=GithubActions&style=flat-square)](https://github.com/shellspec/shellspec/actions)
[![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/shellspec/shellspec?style=flat-square&label=DockerHub)![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/shellspec/shellspec?style=flat-square&label=builds)](https://hub.docker.com/r/shellspec/shellspec)<br>
[![Kcov](https://img.shields.io/badge/dynamic/json.svg?label=Kcov&query=percent_covered&suffix=%25&url=https%3A%2F%2Fcircleci.com%2Fapi%2Fv1.1%2Fproject%2Fgithub%2Fshellspec%2Fshellspec%2Flatest%2Fartifacts%2F0%2Fcoverage%2Fcoverage.json%3Fbranch%3Dmaster&style=flat-square)](https://circleci.com/api/v1.1/project/github/shellspec/shellspec/latest/artifacts/0/coverage/index.html?branch=master)
[![Coveralls](https://img.shields.io/coveralls/github/shellspec/shellspec.svg?label=Coveralls&style=flat-square)](https://coveralls.io/github/shellspec/shellspec?branch=master)
[![Code Climate](https://img.shields.io/codeclimate/coverage/shellspec/shellspec?label=CodeClimate&style=flat-square)](https://codeclimate.com/github/shellspec/shellspec)
[![Codecov](https://img.shields.io/codecov/c/github/shellspec/shellspec.svg?label=Codecov&style=flat-square)](https://codecov.io/gh/shellspec/shellspec)
[![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/shellspec/shellspec?label=CodeFactor&style=flat-square)](https://www.codefactor.io/repository/github/shellspec/shellspec)
[![GitHub top language](https://img.shields.io/github/languages/top/shellspec/shellspec.svg?style=flat-square)](https://github.com/shellspec/shellspec/search?l=Shell)
[![GitHub release](https://img.shields.io/github/release/shellspec/shellspec.svg?style=flat-square)](https://github.com/shellspec/shellspec/releases/latest)
[![License](https://img.shields.io/github/license/shellspec/shellspec.svg?style=flat-square)](https://github.com/shellspec/shellspec/blob/master/LICENSE)

[![bash](https://img.shields.io/badge/bash-&ge;2.03-lightgrey.svg?style=flat)](https://www.gnu.org/software/bash/)
[![bosh](https://img.shields.io/badge/bosh-&ge;2018%2F10%2F07-lightgrey.svg?style=flat)](http://schilytools.sourceforge.net/bosh.html)
[![busybox](https://img.shields.io/badge/busybox-&ge;1.10.2-lightgrey.svg?style=flat)](https://www.busybox.net/)
[![dash](https://img.shields.io/badge/dash-&ge;0.5.2-lightgrey.svg?style=flat)](http://gondor.apana.org.au/~herbert/dash/)
[![ksh](https://img.shields.io/badge/ksh-&ge;93s-lightgrey.svg?style=flat)](http://kornshell.org)
[![mksh](https://img.shields.io/badge/mksh-&ge;28-lightgrey.svg?style=flat)](http://www.mirbsd.org/mksh.htm)
[![posh](https://img.shields.io/badge/posh-&ge;0.3.14-lightgrey.svg?style=flat)](https://salsa.debian.org/clint/posh)
[![yash](https://img.shields.io/badge/yash-&ge;2.30-lightgrey.svg?style=flat)](https://yash.osdn.jp/)
[![zsh](https://img.shields.io/badge/zsh-&ge;3.1.9-lightgrey.svg?style=flat)](https://www.zsh.org/)

## Table of Contents <!-- omit in toc -->

- [Introduction](#introduction)
  - [Features](#features)
  - [Supported shells and platforms](#supported-shells-and-platforms)
  - [Requirements](#requirements)
- [Tutorial](#tutorial)
  - [Installation](#installation)
    - [Web installer](#web-installer)
    - [Package manager](#package-manager)
    - [Others (archive / make / manual)](#others-archive--make--manual)
  - [Use with Docker](#use-with-docker)
  - [Getting started](#getting-started)
- [ShellSpec features](#shellspec-features)
  - [Usage](#usage)
  - [Configure default options](#configure-default-options)
  - [Special environment variables](#special-environment-variables)
  - [Quick execution](#quick-execution)
  - [Parallel execution](#parallel-execution)
  - [Random execution](#random-execution)
  - [Reporter / Generator](#reporter--generator)
  - [Ranges / Filters / Focus](#ranges--filters--focus)
  - [Coverage](#coverage)
  - [Profiler](#profiler)
  - [Task runner](#task-runner)
- [Project directory](#project-directory)
  - [.shellspec](#shellspec)
  - [.shellspec-local](#shellspec-local)
  - [.shellspec-quick.log](#shellspec-quicklog)
  - [report/](#report)
  - [coverage/](#coverage-1)
  - [spec/](#spec)
  - [spec/banner](#specbanner)
  - [spec/spec_helper.sh](#specspec_helpersh)
  - [spec/support/](#specsupport)
- [Specfile](#specfile)
  - [Example](#example)
  - [Translation process](#translation-process)
  - [DSL](#dsl)
    - [Describe, Context - example group](#describe-context---example-group)
    - [It, Example, Specify, Todo - example](#it-example-specify-todo---example)
    - [When - evaluation](#when---evaluation)
    - [The - expectation](#the---expectation)
    - [Skip, Pending - skip and pending example](#skip-pending---skip-and-pending-example)
      - [Temporary skip and pending](#temporary-skip-and-pending)
    - [Include - include a shell script](#include---include-a-shell-script)
    - [Set - set shell option](#set---set-shell-option)
    - [Path, File, Dir - path alias](#path-file-dir---path-alias)
    - [Data - input data for evaluation](#data---input-data-for-evaluation)
    - [Parameters - parameterized example](#parameters---parameterized-example)
    - [Subjects, Modifiers and Matchers](#subjects-modifiers-and-matchers)
    - [Custom subject, modifier and matcher](#custom-subject-modifier-and-matcher)
  - [Hooks](#hooks)
    - [Before, After - example hook](#before-after---example-hook)
    - [BeforeAll, AfterAll - example group hook](#beforeall-afterall---example-group-hook)
    - [BeforeCall, AfterCall - call evaluation hook](#beforecall-aftercall---call-evaluation-hook)
    - [BeforeRun, AfterRun - run evaluation hook](#beforerun-afterrun---run-evaluation-hook)
  - [Directive](#directive)
    - [%const (%) - constant definition](#const----constant-definition)
    - [%text - embedded text](#text---embedded-text)
    - [%puts (%-),  %putsn (%=) - put string](#puts---putsn----put-string)
    - [%logger](#logger)
    - [%data](#data)
  - [Mock and Stub](#mock-and-stub)
  - [Testing a single file script](#testing-a-single-file-script)
    - [Sourced Return](#sourced-return)
    - [Intercept](#intercept)
  - [Self-executable specfile](#self-executable-specfile)
- [For developers](#for-developers)
- [Version history](#version-history)

## Introduction

ShellSpec was developed as a cross-platform testing tool for developing
POSIX-compliant shell scripts that work in many environments.
It not only works on PC but also in restricted environments like cloud and
embedded OS. It provides first-class features equivalent to other language
testing tools. Of course ShellSpec is tested by ShellSpec.

### Features

- Works with all POSIX compliant shells (dash, bash, zsh, ksh, busybox, etc...)
- Implemented by shell scripts with minimal dependencies (use only a few basic POSIX-compliant commands)
- BDD style specfile interpretable as a shell script
- Supports nestable blocks with scope like lexical scope
- Easy to mock and stub in cooperation with scope
- Skip / pending of the examples, and support of easy-to-skip "x" known as "xit"
- Hooks before / after examples
- Parameterized examples for Data-Driven tests
- Execution filtering by line number, id, focus, tag and example name
- Quick execution to run only not-passed examples the last time they ran
- Parallel execution, random ordered execution and dry-run execution
- Modern reporting (colorized, failed line number, progress / documentation / TAP / JUnit formatter)
- Coverage ([Kcov](http://simonkagstrom.github.io/kcov/index.html) integration) and Profiler
- Friendly with Docker and CI
- Builtin simple task runner
- Extensible architecture (custom matcher, custom formatter, etc...)

Subproject: [ShellMetrics](https://github.com/shellspec/shellmetrics) - Cyclomatic Complexity Analyzer

### Supported shells and platforms

`bash`, `busybox (ash)`, `bosh`, `dash`, `gwsh`, `ksh`, `loksh`, `mksh`, `oksh`, `pdksh`, `posh`, `yash`, `zsh`

| Platform                                                         | Test                                                |
| ---------------------------------------------------------------- | --------------------------------------------------- |
| Linux (Debian, Ubuntu, Fedora, CentOS, Alpine, Busybox, OpenWrt) | [Travis CI][TravisCI] or [Docker][Docker] or manual |
| macOS (Default installed shells, Homebrew)                       | [Travis CI][TravisCI] or manual                     |
| Windows (Git bash, msys2, cygwin, busybox-w32, WSL)              | [Cirrus CI][CirrusCI] or manual                     |
| BSD (FreeBSD, OpenBSD, NetBSD)                                   | [Cirrus CI][CirrusCI] or manual                     |
| Unix (Solaris, AIX)                                              | manual only                                         |

[TravisCI]: https://travis-ci.com/shellspec/shellspec
[CirrusCI]: https://cirrus-ci.com/github/shellspec/shellspec
[Docker]: dockerfiles

[Tested version details](docs/shells.md)

### Requirements

ShellSpec is implemented by a pure shell script and uses only shell builtins
and a few basic [POSIX-compliant commands][utilities] to support widely environments
(except `kcov` for optional coverage).

[utilities]: http://pubs.opengroup.org/onlinepubs/9699919799/utilities/contents.html

Currently used external (not shell builtins) commands:

- `cat`, `date`, `env`, `ls`, `mkdir`, `od` (or not POSIX `hexdump`), `rm`, `sleep`, `sort`, `time`
- `ps` (used to autodetect the current shell in environments which do not implement procfs)
- `ln`, `mv` (used only when generating coverage report)
- `kill`, `printf` (used but almost shell builtins)

## Tutorial

### Installation

#### Web installer

**Install the latest release version.**

```sh
curl -fsSL https://git.io/shellspec | sh
```

or

```sh
wget -O- https://git.io/shellspec | sh
```

<details>
<summary>Advanced installation / upgrade / uninstall</summary>

**Install the specified version.**

```sh
curl -fsSL https://git.io/shellspec | sh -s 0.19.1
```

**Upgrade to the latest release version.**

```sh
curl -fsSL https://git.io/shellspec | sh -s -- --switch
```

**Switch to the specified version.**

```sh
curl -fsSL https://git.io/shellspec | sh -s 0.18.0 --switch
```

**How to uninstall.**

1. Delete the ShellSpec executable file [default: `$HOME/bin/shellspec`].
2. Delete the ShellSpec installation directory [default: `$HOME/lib/shellspec`].

**Other usage.**

```console
$ curl -fsSL https://git.io/shellspec | sh -s -- --help
Usage: [sudo] ./install.sh [VERSION] [OPTIONS...]
  or : wget -O- https://git.io/shellspec | [sudo] sh
  or : wget -O- https://git.io/shellspec | [sudo] sh -s -- [OPTIONS...]
  or : wget -O- https://git.io/shellspec | [sudo] sh -s VERSION [OPTIONS...]
  or : curl -fsSL https://git.io/shellspec | [sudo] sh
  or : curl -fsSL https://git.io/shellspec | [sudo] sh -s -- [OPTIONS...]
  or : curl -fsSL https://git.io/shellspec | [sudo] sh -s VERSION [OPTIONS...]

VERSION:
  Specify install version and method

  e.g
    1.0.0           Install 1.0.0 from git
    master          Install master from git
    1.0.0.tar.gz    Install 1.0.0 from tar.gz archive
    .               Install from local directory

OPTIONS:
  -p, --prefix PREFIX   Specify prefix                 [default: $HOME/.local]
  -b, --bin BIN         Specify bin directory          [default: <PREFIX>/bin]
  -d, --dir DIR         Specify installation directory [default: <PREFIX>/lib/shellspec]
  -s, --switch          Switch version (requires installed via git)
  -l, --list            List available versions (tags)
      --pre             Include pre-release
      --fetch FETCH     Force command to use when install from archive (curl or wget)
  -y, --yes             Automatic yes to prompts
  -h, --help            You're looking at it
```

</details>

#### Package manager

<details>
<summary>Arch Linux</summary>

Installation on Arch Linux from the AUR [ShellSpec package](https://aur.archlinux.org/packages/shellspec/) using `aura`:

```console
# Install the latest stable version
$ aura -A shellspec
```

</details>

<details>
<summary>Homebrew / Linuxbrew</summary>

```console
# Install the latest stable version
$ brew tap shellspec/shellspec
$ brew install shellspec
```

</details>

<details>
<summary>basher</summary>

Installation with [basher](https://github.com/basherpm/basher)

**The officially supported version is ShellSpec 0.19.1 and later.**

```console
# Install from master branch
$ basher install shellspec/shellspec

# To specify a version (example: 0.19.1)
$ basher install shellspec/shellspec@0.19.1
```

</details>

<details>
<summary>bpkg</summary>

Installation with [bpkg](https://github.com/bpkg/bpkg)

**The officially supported version is ShellSpec 0.19.1 and later.**

```console
# Install from master branch
$ bpkg install shellspec/shellspec

# To specify a version (example: 0.19.1)
$ bpkg install shellspec/shellspec@0.19.1
```

</details>

#### Others (archive / make / manual)

<details>
<summary>Archive</summary>

See [Releases](https://github.com/shellspec/shellspec/releases) page if you want to download distribution archive.

</details>

<details>
<summary>Make</summary>

**How to install.**

Install to `/usr/local/bin` and `/usr/local/lib`

```sh
sudo make install
```

Install to `$HOME/bin` and `$HOME/lib`

```sh
make install PREFIX=$HOME
```

**How to uninstall.**

```sh
sudo make uninstall
```

```sh
make uninstall PREFIX=$HOME
```

</details>

<details>
<summary>Manual installation</summary>

**Just get ShellSpec and create a symlink in your executable PATH!**

From git

```console
$ cd /SOME/WHERE/TO/INSTALL
$ git clone https://github.com/shellspec/shellspec.git
$ ln -s /SOME/WHERE/TO/INSTALL/shellspec/shellspec /EXECUTABLE/PATH/
# (e.g. /EXECUTABLE/PATH/ = /usr/local/bin/, $HOME/bin/)
```

From tar.gz

```console
$ cd /SOME/WHERE/TO/INSTALL
$ wget https://github.com/shellspec/shellspec/archive/{VERSION}.tar.gz
$ tar xzvf shellspec-{VERSION}.tar.gz

$ ln -s /SOME/WHERE/TO/INSTALL/shellspec-{VERSION}/shellspec /EXECUTABLE/PATH/
# (e.g. /EXECUTABLE/PATH/ = /usr/local/bin/, $HOME/bin/)
```

If you can't create symlink (like default of Git for Windows), create the `shellspec` file.

```console
$ cat<<'HERE'>/EXECUTABLE/PATH/shellspec
#!/bin/sh
exec /SOME/WHERE/TO/INSTALL/shellspec/shellspec "$@"
HERE
$ chmod +x /EXECUTABLE/PATH/shellspec
```

</details>

### Use with Docker

You can run ShellSpec without installation by using Docker. ShellSpec and
specfiles run in a Docker container.

See [How to use ShellSpec with Docker](docs/docker.md).

### Getting started

**Just create your project directory and run `shellspec --init` to setup to your project**

```console
# Create your project directory, for example "hello".
$ mkdir hello
$ cd hello

# Initialize
$ shellspec --init
  create   .shellspec
  create   spec/spec_helper.sh
  create   spec/hello_spec.sh # sample

# Write your first specfile (of course you can use your favorite editor)
$ cat<<'HERE'>spec/hello_spec.sh
Describe 'hello.sh'
  Include lib/hello.sh
  It 'says hello'
    When call hello ShellSpec
    The output should equal 'Hello ShellSpec!'
  End
End
HERE

# Create lib/hello.sh
$ mkdir lib
$ touch lib/hello.sh

# It will fail because the hello function is not implemented.
$ shellspec

# Write hello function
$ cat<<'HERE'>lib/hello.sh
hello() {
  echo "Hello ${1}!"
}
HERE

# It will success!
$ shellspec
```

## ShellSpec features

### Usage

```
Usage: shellspec [options...] [files or directories...]

  Using + instead of - for short options causes reverses the meaning

    -s, --shell SHELL               Specify a path of shell [default: "auto" (current shell)]
        --require MODULE            Require a MODULE (shell script file)
    -e, --env NAME=VALUE            Set environment variable
        --env-from ENV-SCRIPT       Set environment variable from shell script file
    -w, --[no-]warning-as-failure   Treat warning as failure [default: enabled]
        --[no-]fail-fast[=COUNT]    Abort the run after first (or COUNT) of failures [default: disabled]
        --[no-]fail-no-examples     Fail if no examples found [default: disabled]
        --[no-]fail-low-coverage    Fail on low coverage [default: disabled]
                                    The coverage threshold is specified by the coverage option
    -p, --[no-]profile              Enable profiling and list the slowest examples [default: disabled]
                                      Profiler tries to use 100% ability of 1 CPU (1 core).
                                      Therefore, not recommended for single(-core) CPU.
        --profile-limit N           List the top N slowest examples [default: 10]
        --[no-]boost                Increase the CPU frequency to boost up testing speed [default: disabled]
                                      Equivalent of --profile --profile-limit 0
                                      (Don't worry, this is not overclocking. This is joke option but works.)
        --log-file LOGFILE          Logfile for %logger directive [default: /dev/tty]
        --keep-tempdir              Do not cleanup temporary directory [default: disabled]

  **** Execution ****

    -q, --[no-]quick                Run not-passed examples if it exists, otherwise run all [default: disabled]
                                      not-passed examples: failure and temporary pending examples
                                      Quick mode is automatically enabled. To disable quick mode,
                                      delete .shellspec-quick.log on the project root directory.
        --repair, --only-failures   Run failure examples only (Depends on quick mode)
    -n, --next,   --next-failure    Run failure examples and abort on first failure (Depends on quick mode)
                                      Equivalent of --repair --fail-fast --random none
    -j, --jobs JOBS                 Number of parallel jobs to run [default: 0 (disabled)]
        --random TYPE[:SEED]        Run examples by the specified random type
                                      [none]          run in the defined order [default]
                                      [specfiles]     randomize the order of specfiles
                                      [examples]      randomize the order of examples (slow)
        --dry-run                   Print the formatter output without running any examples [default: disabled]

  **** Output ****

        --[no-]banner               Show banner if exist 'spec/banner' [default: enabled]
    -f, --format FORMATTER          Choose a formatter for display
                                      [p]rogress      dots [default]
                                      [d]ocumentation group and example names
                                      [t]ap           TAP format
                                      [j]unit         JUnit XML (time attributre with --profile)
                                      [f]ailures      file:line:message (suitable for editors integration)
                                      [null]          do not display anything
                                      [debug]         for developers
                                      custom formatter name
    -o, --output GENERATOR          Choose a generator(s) to generate a report file(s) [default: none]
                                      You can use the same name as FORMATTER. (multiple options allowed)
        --[no-]color                Enable or disable color [default: enabled if the output is a TTY]
                                      Disable if NO_COLOR environment variable set
        --skip-message VERBOSITY    Mute skip message
                                      [verbose]       do not mute any messages [default]
                                      [moderate]      mute repeated messages
                                      [quiet]         mute repeated or non-temporary messages
        --pending-message VERBOSITY Mute pending message
                                      [verbose]       do not mute any messages [default]
                                      [quiet]         mute non-temporary messages
        --quiet                     Equivalent of --skip-message quiet --pending-message quiet
        --(show|hide)-deprecations  Show or hide deprecations details [default: show]

  **** Ranges / Filters / Focus ****

    You can run selected examples by specified the line numbers or ids

      shellspec path/to/a_spec.sh:10    # Run the groups or examples that includes lines 10
      shellspec path/to/a_spec.sh:@1-5  # Run the 5th groups/examples defined in the 1st group
      shellspec a_spec.sh:10:@1:20:@2   # You can mixing multiple line numbers and ids with join by ':'

    -F, --focus                     Run focused groups / examples only
    -P, --pattern PATTERN           Load files matching pattern [default: "*_spec.sh"]
    -E, --example PATTERN           Run examples whose names include PATTERN
    -T, --tag TAG[:VALUE]           Run examples with the specified TAG
    -D, --default-path PATH         Set the default path where looks for examples [defualt: "spec"]

  **** Coverage ****

        --[no-]kcov                 Enable coverage using kcov [default: disabled]
                                      Requires kcov (v35 or later) and bash/zsh/ksh, parallel execution is ignored.
        --kcov-path PATH            Specify kcov path [default: kcov]
        --kcov-options OPTIONS      Additional Kcov options (coverage limits, coveralls id, etc)
                                      Default specified options: (can be overwritten)
                                        --include-path=.
                                        --include-pattern=.sh
                                        --exclude-pattern=/.shellspec,/spec/,/coverage/,/report/
                                        --path-strip-level=1
                                      To include files without extension, specify --include-pattern
                                      without '.sh' and filter with --include-*/--exclude-* options

  **** Utility ****

        --init [TEMPLATE...]        Initialize your project with ShellSpec
                                      Template: Create additional files
                                        [git]   .gitignore
                                        [hg]    .hgignore
                                        [svn]   .svnignore
        --count                     Count the number of specfiles and examples
        --list LIST                 List the specfiles/examples
                                      [specfiles]       list the specfiles
                                      [examples]        list the examples with id
                                      [examples:id]     alias for examples
                                      [examples:lineno] list the examples with lineno
                                      [debug]           for developer
                                      The order is randomized with --random but random TYPE is ignored
        --syntax-check              Syntax check of the specfiles without running any examples
        --translate                 Output translated specfile
        --task [TASK]               Run the TASK or Show the task list if TASK is not specified
    -v, --version                   Display the version
    -h, --help                      -h: short help, --help: long help
```

### Configure default options

To change the default options for the `shellspec` command, create an options
file. Files are read in the order shown below, options defined last take
precedence.

1. `$XDG_CONFIG_HOME/shellspec/options`
2. `$HOME/.shellspec`
3. `./.shellspec`
4. `./.shellspec-local` (Do not store in VCS such as git)

### Special environment variables

Special environment variables understood by ShellSpec begin with `SHELLSPEC_`.
They can be overridden with a custom script using the `--env-from` option.

*Todo: descriptions of many special environment variables.*

### Quick execution

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

### Parallel execution

You can use parallel execution for fast test with `--jobs` option. Parallel
jobs are executed per specfile. So it is necessary to separate the specfile
for effective parallel execution.

### Random execution

You can randomize the execution order to detect troubles due to the test
execution order. If `SEED` is specified, the execution order is deterministic.

### Reporter / Generator

You can specify one reporter (output to stdout) and multiple generators
(output to a file). Currently builtin formatters are `progress`,
`documentation`, `tap`, `junit`, `failures`, `null`, `debug`.

NOTE: Custom formatter is supported (but not documented yet, sorry).

### Ranges / Filters / Focus

You can run specific example(s) or example group(s) only.

It can be specified by line number (`a_spec.sh:10:20`), example id (`a_spec.sh:@1-5:@1-6`),
example name (`--example` option), tag (`--tag` option) and focus (`--focus` option).

To focus, prepend `f` to groups / examples in specfiles (e.g. `Describe` -> `fDescribe`, `It` -> `fIt`)
and run with `--focus` option.

### Coverage

ShellSpec has integrated coverage feature. To use this feature [Kcov][] (v35 or later) is required.

[Kcov]: https://github.com/SimonKagstrom/kcov

- How to [install kcov](https://github.com/SimonKagstrom/kcov/blob/master/INSTALL.md).
- Shells that support coverage are **bash**, **zsh**, and **ksh**.
- Coverage measures only Evaluation and `Include`

By default only files whose names contain `.sh` are coverage targeted.
If you want to include other files, you need to adjust options with `--kcov-options`.

```sh
# Default kcov (coverage) options
--kcov-options "--include-path=. --path-strip-level=1"
--kcov-options "--include-pattern=.sh"
--kcov-options "--exclude-pattern=/.shellspec,/spec/,/coverage/,/report/"

# Example: Include script "myprog" with no extension
--kcov-options "--include-pattern=.sh,myprog"

# Example: Only specified files/directories
--kcov-options "--include-pattern=myprog,/lib/"
```

[Coverage report][] and `cobertura.xml` and `sonarqube.xml` files are generated under the `coverage` directory by Kcov.
You can easily integrate with [Coveralls](https://coveralls.io/), [Code Climate](https://codeclimate.com/),
[Codecov](https://codecov.io/) and more.

[Coverage report]: https://circleci.com/api/v1.1/project/github/shellspec/shellspec/latest/artifacts/0/coverage/index.html

### Profiler

When the `--profile` option is specified, the profiler is enabled and lists the slow examples.

### Task runner

You can run the task with `--task` option.

## Project directory

Typical directory structure.

```
Project directory
├─ .shellspec                 [Required]
├─ .shellspec-local           [Optional, Ignore from VCS]
├─ .shellspec-quick.log       [Optional, Ignore from VCS]
├─ report/                    [Optional, Ignore from VCS]
├─ coverage/                  [Optional, Ignore from VCS]
│
├─ bin/
│   ├─ your_script1.sh
│              :
├─ lib/
│   ├─ your_library1.sh
│              :
├─ libexec/
│   ├─ project-your_script1.sh
│              :
├─ spec/
│   ├─ banner                 [Optional]
│   ├─ spec_helper.sh         [Required]
│   ├─ support/               [Optional]
│   │
│   ├─ bin/
│   │   ├─ your_script1_spec.sh
│   │             :
│   ├─ lib/
│   │   ├─ your_library1_spec.sh
│   │             :
│   ├─ libexec/
│   │   ├─ project-your_script1_spec.sh
│                  :
```

### .shellspec

Project default options for `shellspec` command.

### .shellspec-local

Override the project default options to your favorite.

### .shellspec-quick.log

Log file used for Quick execution.

### report/

Directory where the generator outputs reports.

### coverage/

Directory where kcov outputs coverage reports.

### spec/

Directory where you create specfiles.

### spec/banner

If `spec/banner` file exists, the banner is shown when the `shellspec` command
is executed. Disable that behavior with the `--no-banner` option.

### spec/spec_helper.sh

The *spec_helper.sh* loaded by the `--require spec_helper` option.
This file is used to prepare for running examples, to define custom matchers,
etc.

### spec/support/

This directory is used to store files for custom matchers, tasks, etc.

## Specfile

### Example

**The best place to learn how to write a specfile is the
[sample/spec](/sample/spec) directory. You should take a look at it !**
*(Those samples include failure examples on purpose.)*

```sh
Describe 'sample' # example group
  Describe 'bc command'
    add() { echo "$1 + $2" | bc; }

    It 'performs addition' # example
      When call add 2 3 # evaluation
      The output should eq 5  # expectation
    End
  End

  Describe 'implemented by shell function'
    Include ./mylib.sh # add() function defined

    It 'performs addition'
      When call add 2 3
      The output should eq 5
    End
  End
End
```

### Translation process

The specfile is a valid shell script, but a translation process is performed
to implement the scope, line number etc. Each example group block and
example block is translated to commands in a subshell. Therefore changes inside
those blocks do not affect the outside of the block. In other words it realizes
local variables and local functions in the specfile. This is very useful for
describing a structured spec. If you are interested in how to translate,
use the `--translate` option.

### DSL

#### Describe, Context - example group

You can write a structured *example* by using the `Describe`, `Context` block.
Example groups can be nested. They can contain example groups or examples.
Each example group runs in a subshell.

#### It, Example, Specify, Todo - example

You can describe how code behaves by using the `It`, `Example`, `Specify` block.
It is composed by a maximum of one evaluation and multiple expectations.
`Todo` is a one liner empty example.

#### When - evaluation

Defines the action for verification. The evaluation begins with `When`.
Only one evaluation can be defined for each example.

```
When call echo hello world
 |    |    |
 |    |    +-- The rest is action for verification
 |    +-- The evaluation type `call` calls a function or external command.
 +-- The evaluation keyword
```

There are two types of evaluation, `When call` and `When run`. and `When run` has sub types of `command`, `script` and `source`.

See more details of [Evaluation](/docs/references.md#evaluation)

#### The - expectation

Defines the verification. The expectation begins with `The`.

Verifies the *subject* with the *matcher*.

```
The output should equal 4
 |    |           |
 |    |           +-- The `equal` matcher verifies the subject value is 4.
 |    +-- The `output` subject uses the stdout as a subject for verification.
 +-- The expectation keyword
```

You can reverse the verification with *should not*.

```sh
The output should not equal 4
```

You can use the *modifier* to modify the *subject*.

```
The line 2 of output should equal 4
    |
    +-- The `line` modifier use the specified line 2 of output as subject.
```

The *modifier* is chainable.

```sh
The word 1 of line 2 of output should equal 4
```

You can use ordinal numbers.

```sh
The second line of output should equal 4
```

ShellSpec supports *language chains* like [chai.js](https://www.chaijs.com/).
It only improves readability, does not affect the expectation:

- a
- an
- as
- the

The following two sentences have the same meaning:

```sh
The first word of second line of output should valid number
```

```sh
The first word of the second line of output should valid as a number
```

#### Skip, Pending - skip and pending example

You can skip an example by using the `Skip` keyword. If you want to skip only in
some cases, use a conditional skip `Skip if`. You can also use `Pending` to
indicate that the example needs to be implemented.

##### Temporary skip and pending

The (non-temporary) skip and pending is for long term skip and pending.
It need time to resolve and it may commit to a version control system.

The temporary skip and pending is for short term skip and pending.
Used during the current work, do not commit to a version control system.

The skip and pending without message is temporary skip and pending.

```sh
Skip "some reason" # Skip with message is non-temporary skip
Skip if "reason" condition # Skip with condition is also non-temporary skip
Skip # temporary skip (this is comment but will be displayed in the report)
```

You can also temporary skip with blocks by prefixing with `x`
(`xDescribe`, `xContext`, `xExample`, `xSpecify`, `xIt`).

`Todo` (and empty example) is also treated as temporary pending.

#### Include - include a shell script

Include the shell script file to test.

#### Set - set shell option

Set shell option before executing each example.
The shell option name is the long name of `set` or the name of `shopt`:

```sh
Set 'errexit:off' 'noglob:on'
```

#### Path, File, Dir - path alias

*TODO*

#### Data - input data for evaluation

You can use the Data Helper which inputs data from stdin for evaluation.
The input data is specified after `#|` in the `Data` block.

```sh
Describe 'Data helper'
  Example 'provide with Data helper block style'
    Data
      #|item1 123
      #|item2 456
      #|item3 789
    End
    When call awk '{total+=$2} END{print total}'
    The output should eq 1368
  End
End
```

#### Parameters - parameterized example

You can Data Driven Test (aka Parameterized Test) with `Parameters`.

Note: Multiple `Parameters` definitions are merged.

```sh
Describe 'example'
  Parameters
    "#1" 1 2 3
    "#2" 1 2 3
  End

  Example "example $1"
    When call echo "$(($2 + $3))"
    The output should eq "$4"
  End
End
```

The following four styles are supported.

```sh
# block style (default: same as Parameters)
Parameters:block
  "#1" 1 2 3
  "#2" 1 2 3
End

# value style
Parameters:value foo bar baz

# matrix style
Parameters:matrix
  foo bar
  1 2
  # expanded as follows
  #   foo 1
  #   foo 2
  #   bar 1
  #   bar 2
End

# dynamic style
#   Only %data directive can be used within Parameters:dynamic block.
#   You can not call function or accessing variable defined within specfile.
#   You can refer to variables defined with %const.
Parameters:dynamic
  for i in 1 2 3; do
    %data "#$i" 1 2 3
  done
End
```

#### Subjects, Modifiers and Matchers

There are many *subjects*, *modifiers*, *matchers*. please refer to the
[References](docs/references.md)

#### Custom subject, modifier and matcher

You can create custom subject, custom modifier and custom matcher.
See [sample/spec/support/custom_matcher.sh](sample/spec/support/custom_matcher.sh) for custom matcher.

NOTE: If you want to assert using shell function, Use [result](docs/references.md#result) modifier or
[result](docs/references.md#satisfy) matcher. Do not need create custom matcher.

### Hooks

#### Before, After - example hook

You can define before / after hooks by using `Before`, `After`.
The hooks are called for each example.

NOTE: `After` hook is a place to clean up, not an assertion. If you want to assert in the `After` hook,
What you are looking for is probably [result](docs/references.md#result) modifier.

#### BeforeAll, AfterAll - example group hook

You can define before all / after all hooks by using `BeforeAll`, `AfterAll`.
The hooks are called before or after all examples.

#### BeforeCall, AfterCall - call evaluation hook

You can define before / after call hooks by using `BeforeCall`, `AfterCall`.
The hooks are called before or after a "call evaluation".

#### BeforeRun, AfterRun - run evaluation hook

You can define before / after run hooks by using `BeforeRun`, `AfterRun`.
The hooks are called before or after a "run evaluation".

These hooks are executed in the same subshell as the "run evaluation". So you
can mock/stub the function before run. And you can access a variable for
evaluation after run.

### Directive

#### %const (%) - constant definition

`%const` (`%` is short hand) directive defines a constant value. The characters
which can be used for variable names are uppercase letters `[A-Z]`, digits
`[0-9]` and underscore `_` only. It can not be defined inside an example
group nor an example.

The value is evaluated during the specfile translation process.
So you can access ShellSpec variables, but you can not access variable or
function in the specfile.

This feature assumed use with conditional skip. The conditional skip may runs
outside of the examples. As a result, sometime you may need variables defined
outside of the examples.

#### %text - embedded text

You can use the `%text` directive instead of an hard-to-use heredoc with
indented code. The input data is specified after `#|`.

```sh
Describe '%text directive'
  It 'outputs texts'
    output() {
      echo "start" # you can write code here
      %text
      #|aaa
      #|bbb
      #|ccc
      echo "end" # you can write code here
    }

    When call output
    The line 1 of output should eq 'start'
    The line 2 of output should eq 'aaa'
    The line 3 of output should eq 'bbb'
    The line 4 of output should eq "ccc"
    The line 5 of output should eq 'end'
  End
End
```

#### %puts (%-),  %putsn (%=) - put string

`%puts` (put string) and `%putsn` (put string with newline) can be used instead
of (not portable) echo. Unlike echo, it does not interpret escape sequences
regardless of the shell. `%-` is an alias of `%puts`, `%=` is an alias of
`%putsn`.

#### %logger

Output log to `$SHELLSPEC_LOGFILE` (default: `/dev/tty`) for debugging.

#### %data

See `Parameters`.

### Mock and Stub

Currently, ShellSpec does not provide any special function for mocking / stubbing.
But redefining a shell function can override existing shell function or external
command. It can be used for mocking / stubbing.

Remember that `Describe`, `Context`, `It`, `Example`, `Specify` blocks run in a
subshell. When going out of the block, redefined functions are restored.

```sh
Describe 'mock stub sample'
  unixtime() { date +%s; }
  get_next_day() { echo $(($(unixtime) + 86400)); }

  Example 'redefine date command'
    date() { echo 1546268400; }
    When call get_next_day
    The stdout should eq 1546354800
  End

  Example 'use the date command'
    # date is not redefined because this is another subshell
    When call unixtime
    The stdout should not eq 1546268400
  End
End
```

### Testing a single file script

Shell scripts are often made up of a single file. ShellSpec provides two ways
of testing a single shell script.

#### Sourced Return

This is a method for testing functions defined in shell scripts. Loading a
script with `Include` defines a `__SOURCED__` variable available in the sourced
script. If the `__SOURCED__` variable is defined, return in your shell script
process.

```sh
#!/bin/sh
# hello.sh

hello() { echo "Hello $1"; }

${__SOURCED__:+return}

hello "$1"
```

```sh
Describe "sample"
  Include "./hello.sh"
  Example "hello test"
    When call hello world
    The output should eq "Hello world"
  End
End
```

#### Intercept

This is a method to mock/stub functions and commands when executing shell
scripts. By placing intercept points in your script, you can call the hooks
defined in specfile.

```sh
#!/bin/sh
# today.sh

test || __() { :; }

__ begin __

date +"%A, %B %d, %Y"
```

```sh
Describe "sample"
  Intercept begin
  __begin__() {
    date() {
      export LANG=C
      command date "$@" --date="2019-07-19"
    }
  }
  Example "today test"
    When run source ./today.sh
    The output should eq "Friday, July 19, 2019"
  End
End
```

### Self-executable specfile

Normally, you use shellspec to run the specfile. But you can run it directly
by adding `eval "$(shellspec -)"` to the top of the specfile.

```sh
#!/bin/sh
# 'test.sh' with executable permission

eval "$(shellspec -)"

Describe "bc command"
  bc() { echo "$@" | command bc; }

  It "performs addition"
    When call bc "2+3"
    The output should eq 5
  End
End
```

```sh
# You can run 'test.sh' directly
$ ./test.sh
Running: /bin/sh [sh]
.

Finished in 0.12 seconds (user 0.00 seconds, sys 0.10 seconds)
1 example, 0 failures

# Also you can run via shellspec
$ shellspec test.sh
```

## For developers

If you want to know ShellSpec architecture and self test, see [CONTRIBUTING.md](CONTRIBUTING.md)

## Version history

See [Changelog](CHANGELOG.md)
