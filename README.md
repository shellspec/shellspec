# shellspec

BDD style unit testing framework for POSIX compliant shell script.

**Let’s test the your shell script!**

![demo](docs/demo.gif)

[![Travis CI](https://img.shields.io/travis/shellspec/shellspec/master.svg?label=TravisCI)](https://travis-ci.org/shellspec/shellspec)
[![Cirrus CI](https://img.shields.io/cirrus/github/shellspec/shellspec.svg?label=CirrusCI)](https://cirrus-ci.com/github/shellspec/shellspec)
[![Circle CI](https://img.shields.io/circleci/build/github/shellspec/shellspec.svg?label=CircleCI)](https://circleci.com/gh/shellspec/shellspec)
[![Kcov](https://img.shields.io/badge/dynamic/json.svg?label=kcov&query=percent_covered&suffix=%25&url=https%3A%2F%2Fcircleci.com%2Fapi%2Fv1.1%2Fproject%2Fgithub%2Fshellspec%2Fshellspec%2Flatest%2Fartifacts%2F0%2Froot%2Fshellspec%2Fcoverage%2Fcoverage.json%3Fbranch%3Dmaster)](https://circleci.com/api/v1.1/project/github/shellspec/shellspec/latest/artifacts/0/root/shellspec/coverage/index.html?branch=master)
[![Coveralls](https://img.shields.io/coveralls/github/shellspec/shellspec.svg?label=coveralls)](https://coveralls.io/github/shellspec/shellspec?branch=master)
[![Codecov](https://img.shields.io/codecov/c/github/shellspec/shellspec.svg?label=codecov)](https://codecov.io/gh/shellspec/shellspec)
[![CodeFactor](https://www.codefactor.io/repository/github/shellspec/shellspec/badge)](https://www.codefactor.io/repository/github/shellspec/shellspec)
[![GitHub top language](https://img.shields.io/github/languages/top/shellspec/shellspec.svg)](https://github.com/shellspec/shellspec/search?l=Shell)
[![GitHub release](https://img.shields.io/github/release/shellspec/shellspec.svg)](https://github.com/shellspec/shellspec/releases/latest)
[![License](https://img.shields.io/github/license/shellspec/shellspec.svg)](https://github.com/shellspec/shellspec/blob/master/LICENSE)

![bash](https://img.shields.io/badge/bash-%3E%3D2.03-lightgrey.svg?style=plastic)
![busybox](https://img.shields.io/badge/busybox-%3E%3D1.10.2-lightgrey.svg?style=plastic)
![dash](https://img.shields.io/badge/dash-%3E%3D0.5.2-lightgrey.svg?style=plastic)
![ksh](https://img.shields.io/badge/ksh-%3E%3D93s-lightgrey.svg?style=plastic)
![mksh](https://img.shields.io/badge/mksh-%3E%3D28-lightgrey.svg?style=plastic)
![posh](https://img.shields.io/badge/posh-%3E%3D0.3.14-lightgrey.svg?style=plastic)
![yash](https://img.shields.io/badge/yash-%3E%3D2.30-lightgrey.svg?style=plastic)
![zsh](https://img.shields.io/badge/zsh-%3E%3D3.1.9-lightgrey.svg?style=plastic)

**Project status: Implementation of practical features has been completed.**
**I will add more tests and improve the documentation.**

*Table of Contents*

- [Introduction](#introduction)
  - [Features](#features)
  - [Supported shells](#supported-shells)
  - [Requires](#requires)
- [Tutorial](#tutorial)
  - [Installation](#installation)
  - [Getting started](#getting-started)
- [shellspec command](#shellspec-command)
  - [Usage](#usage)
  - [Configure default options](#configure-default-options)
  - [Special environment variable](#special-environment-variable)
  - [Parallel execution](#parallel-execution)
  - [Random execution](#random-execution)
  - [Reporter / Generator](#reporter--generator)
  - [Ranges / Filters](#ranges--filters)
  - [Coverage](#coverage)
  - [Profiler](#profiler)
  - [Task runner](#task-runner)
- [Project directory](#project-directory)
  - [.shellspec](#shellspec)
  - [.shellspec-local](#shellspec-local)
  - [report/](#report)
  - [coverage/](#coverage)
  - [spec/](#spec)
  - [banner](#banner)
  - [spec_helper.sh](#spechelpersh)
  - [support/](#support)
- [Specfile](#specfile)
  - [Example](#example)
  - [Translation process](#translation-process)
  - [DSL](#dsl)
    - [Describe, Context - example group](#describe-context---example-group)
    - [It, Example, Specify, Todo - example](#it-example-specify-todo---example)
    - [When - evaluation](#when---evaluation)
    - [The - expectation](#the---expectation)
    - [Skip, Pending - skip and pending example](#skip-pending---skip-and-pending-example)
    - [Include - include shell script](#include---include-shell-script)
    - [Set - set shell option](#set---set-shell-option)
    - [Path, File, Dir - path alias](#path-file-dir---path-alias)
    - [Data - input data for evaluation](#data---input-data-for-evaluation)
    - [Parameters - parameterized example](#parameters---parameterized-example)
    - [subject, modifier, matcher](#subject-modifier-matcher)
  - [Hooks](#hooks)
    - [Before, After - example hook](#before-after---example-hook)
    - [BeforeCall, AfterCall - call evaluation hook](#beforecall-aftercall---call-evaluation-hook)
    - [BeforeRun, AfterRun - run evaluation hook](#beforerun-afterrun---run-evaluation-hook)
  - [Directive](#directive)
    - [%const (%) - constant definition](#const----constant-definition)
    - [%text - embedded text](#text---embedded-text)
    - [%puts (%-), %putsn (%=) - put string](#puts---putsn----put-string)
    - [%logger](#logger)
    - [%data](#data)
  - [Mock and Stub](#mock-and-stub)
  - [Testing a single file script.](#testing-a-single-file-script)
    - [Sourced Return](#sourced-return)
    - [Intercept](#intercept)
- [For developers](#for-developers)
- [Version history](#version-history)

## Introduction

shellspec was developed as a cross-platform testing tool for develop
POSIX-compliant shell scripts that work in many environments.
Works not only PC but also in restricted environments like cloud and embedded OS.
And provides first-class features equivalent to other language testing tools.
Of course shellspec is tested by shellspec.

### Features

* Works with all POSIX compliant shells (dash, bash, zsh, ksh, busybox, etc...)
* Implemented by shell script with minimal dependencies (use only a few basic POSIX compliant command)
* BDD style syntax specfile that interpretable as a shell script
* Support nestable block with scope like lexical scope
* Easy to mocking and stubbing in cooperation with scope
* The skip / pending of the examples, and support easy-to-skip "x" known as "xit"
* The before / after examples hooks
* Parameterized example for Data-Driven tests
* Execution filtering by line number, id, focus, tag and example name
* Parallel execution, random ordering execution and dry-run execution
* Modern reporting (colorize, failed line number, progress / documentation / TAP / JUnit formatter)
* Coverage ([kcov](http://simonkagstrom.github.io/kcov/index.html) integration) and Profiler
* Built-in simple task runner
* Extensible architecture (custom matcher, custom formatter, etc...)

### Supported shells

`dash`, `bash`, `ksh`, `mksh`, `oksh`, `pdksh`, `zsh`, `posh`, `yash`, `busybox (ash)`, `bosh`, `pbosh`

Tested Platforms

| Platform                                                  | Test                                                          |
| --------------------------------------------------------- | ------------------------------------------------------------- |
| Ubuntu 12.04, 14.04, 16.04, 18.04                         | [Travis CI](https://travis-ci.org/shellspec/shellspec)        |
| macOS 10.10, 10.11, 10.12, 10.13, 10.14, 10.14 (Homebrew) | [Travis CI](https://travis-ci.org/shellspec/shellspec)        |
| FreeBSD 10.x, 11.x, 12.x                                  | [Cirrus CI](https://cirrus-ci.com/github/shellspec/shellspec) |
| Windows Server 2019 (Git bash, msys2, cygwin)             | [Cirrus CI](https://cirrus-ci.com/github/shellspec/shellspec) |
| Debian 2.2, 3.0, 3.1, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0  | docker                                                        |
| Alpine, BusyBox, LEDE 17.01, OpenWrt 18.06                | docker                                                        |
| Windows 10 1903 (Ubuntu 18.04 on WSL)                     | manual                                                        |
| Solaris 10, 11                                            | manual                                                        |

[Tested version details](docs/shells.md)

### Requires

shellspec is implemented by a pure shell script and uses only shell built-in
and a few basic [POSIX-compliant commands][utilities] to support widely environments.
(except `kcov` for optionally coverage).

[utilities]: http://pubs.opengroup.org/onlinepubs/9699919799/utilities/contents.html

Currently used external (not shell built-in) commands.

- `cat`, `date`, `ls`, `mkdir`, `od` (or `hexdump` not posix), `rm`, `sleep`, `sort`, `time`
- `ps` (Used to auto detect the current shell in environments that do not implement procfs)
- `ln` (Used only when generating coverage)
- `kill`, `printf` (Used but almost shell built-in)

## Tutorial

### Installation

**Install the latest release version.**

```console
$ curl -fsSL https://git.io/shellspec | sh
```

or

```console
$ wget -O- https://git.io/shellspec | sh
```

<details>
<summary>Advanced installation / upgrade / uninstall</summary>

**Install the specified version.**

```console
$ curl -fsSL https://git.io/shellspec | sh -s 0.19.1
```

**Upgrade to the latest release version.**

```console
$ curl -fsSL https://git.io/shellspec | sh -s -- --switch
```

**Switch to the specified version.**

```console
$ curl -fsSL https://git.io/shellspec | sh -s 0.18.0 --switch
```

**Uninstall**

1. Delete the shellspec executable file [default: `$HOME/bin/shellspec`].
2. Delete the shellspec installation directpry [default: `$HOME/lib/shellspec`].

**Other usage**

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
  -p, --prefix PREFIX   Specify prefix                 [default: $HOME]
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

<details>
<summary>Using package manager (basher / bpkg)</summary>

**The official support is shellspec 0.19.1 and later.**

Installation with [basher](https://github.com/basherpm/basher)

```console
# Install from master branch
$ basher install shellspec/shellspec

# To specify a version (example: 0.19.1)
$ basher install shellspec/shellspec@0.19.1
```

Installation with [bpkg](https://github.com/bpkg/bpkg)

```console
# Install from master branch
$ bpkg install shellspec/shellspec

# To specify a version (example: 0.19.1)
$ bpkg install shellspec/shellspec@0.19.1
```

</details>

<details>
<summary>Using make</summary>

**Installation**

Install to `/usr/local/bin` and `/usr/local/lib`

```console
$ sudo make install
```

Install to `$HOME/bin` and `$HOME/lib`

```console
$ make install PREFIX=$HOME
```

**Uninstallation**

```console
$ sudo make uninstall
```

```console
$ make uninstall PREFIX=$HOME
```
</details>

<details>
<summary>Manual installation</summary>

**Just get the shellspec and create a symlink in your executable PATH!**

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

### Getting started

**Just create your project directory and run `shellspec --init` to setup to your project**

```console
# Create your project directory. for example "hello".
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
    When call hello shellspec
    The output should equal 'Hello shellspec!'
  End
End
HERE

# Create lib/hello.sh
$ mkdir lib
$ touch lib/hello.sh

# It goes fail because hello function not implemented.
$ shellspec

# Write hello function
$ cat<<'HERE'>lib/hello.sh
hello() {
  echo "Hello ${1}!"
}
HERE

# It goes success!
$ shellspec
```

## shellspec command

### Usage

```
Usage: shellspec [options] [files or directories]

  -s, --shell SHELL                   Specify a path of shell [default: current shell]
      --[no-]fail-fast[=COUNT]        Abort the run after a certain number of failures [default: 1]
      --[no-]fail-no-examples         Fail if no examples found [default: disabled]
      --[no-]fail-low-coverage        Fail on low coverage [default: disabled]
                                        The coverage threshold is specified by the coverage option
  -r, --require MODULE                Require a file
  -e, --env NAME=VALUE                Set environment variable
      --env-from ENV-SCRIPT           Set environment variable from script file
      --random TYPE[:SEED]            Run examples by the specified random type
                                        [none]      run in the defined order [default]
                                        [specfiles] randomize the order of specfiles
                                        [examples]  randomize the order of examples (slow)
  -j, --jobs JOBS                     Number of parallel jobs to run (0 jobs means disabled)
      --[no-]warning-as-failure       Treat warning as failure [default: enabled]
      --dry-run                       Print the formatter output without running any examples
      --keep-tempdir                  Do not cleanup temporary directory [default: disabled]

  **** Output ****

      --[no-]banner                   Show banner if exist 'spec/banner' [default: enabled]
  -f, --format FORMATTER              Choose a formatter to use for display
                                        [p]rogress      dots [default]
                                        [d]ocumentation group and example names
                                        [t]ap           TAP format
                                        [j]unit         JUnit XML
                                                        (Require --profile for time attributre)
                                        [null]          do not display anything
                                        [debug]         for developer
                                        custom formatter name
  -o, --output GENERATOR              Choose a generator(s) to generate a report file(s)
                                        You can use the same name as FORMATTER
                                        Multiple options can be specified [default: not specified]
      --force-color, --force-colour   Force the output to be in color, even if the output is not a TTY
      --no-color, --no-colour         Force the output to not be in color, even if the output is a TTY
      --skip-message VERBOSITY        Mute skip message
                                        [verbose]  do not mute any messages [default]
                                        [moderate] mute repeated messages
                                        [quiet]    mute repeated messages and non-temporarily messages
  -p  --[no-]profile                  Enable profiling of examples and list the slowest examples
      --profile-limit N               List the top N slowest examples (default: 10)

  **** Ranges / Filters ****

    You can select examples range to run by appending the line numbers or id to the filename

      shellspec path/to/a_spec.sh:10:20     # Run the groups or examples that includes lines 10 and 20
      shellspec path/to/a_spec.sh:@1-5:@1-6 # Run the 5th and 6th groups/examples defined in the 1st group

    You can filter examples to run with the following options

      --focus                         Run focused groups / examples only
                                        To focus, prepend 'f' to groups / examples in specfiles
                                        e.g. Describe -> fDescribe, It -> fIt
      --pattern PATTERN               Load files matching pattern [default: "*_spec.sh"]
      --example PATTERN               Run examples whose names include PATTERN
      --tag TAG[:VALUE]               Run examples with the specified TAG
      --default-path PATH             Set the default path where shellspec looks for examples [defualt: "spec"]

  **** Coverage ****

      --[no-]kcov                     Enable coverage using kcov [default: disabled]
                                        Note: Requires kcov and bash, parallel execution is ignored.
      --kcov-path PATH                Specify kcov path [default: kcov]
      --kcov-common-options OPTIONS   Specify kcov common options [default: see below]
                                        --path-strip-level=1
                                        --include-path=.
                                        --include-pattern=.sh
                                        --exclude-pattern=/spec/,/coverage/,/report/
      --kcov-options OPTIONS          Specify additional kcov options
                                        coverage limits, coveralls id, etc...

  **** Utility ****

      --init                          Initialize your project with shellspec
      --count                         Count the number of specfiles and examples
      --list LIST                     List the specfiles / examples
                                        [specfiles]       list the specfiles
                                        [examples]        list the examples with id
                                        [examples:id]     alias for examples
                                        [examples:lineno] list the examples with lineno
                                        [debug]           for developer
                                        affected by --random but TYPE is ignored
      --syntax-check                  Syntax check of the specfiles without running any examples
      --translate                     Output translated specfile
      --task [TASK]                   Run task. If TASK is not specified, show the task list
  -v, --version                       Display the version
  -h, --help                          You're looking at it
```

### Configure default options

To change default options for `shellspec` command, create options file.
Read files in the order the bellows and overrides options.

1. `$XDG_CONFIG_HOME/shellspec/options`
2. `$HOME/.shellspec`
3. `./.shellspec`
4. `./.shellspec-local` (Do not store in VCS such as git)

### Special environment variable

Special environment variable of shellspec is starts with `SHELLSPEC_`.
It can be overridden with custom script of `--env-from` option.

*Todo: descriptions of many special environment variables.*

### Parallel execution

You can use parallel execution for fast test with `--jobs` option. Parallel
jobs are executed per the specfile. So it is necessary to separete the specfile
for effective parallel execution.

### Random execution

You can randomize the execution order to detect troubles due to
the test execution order. If `SEED` specified, you can execute same order.

### Reporter / Generator

You can specify one reporter (output to stdout) and multiple generators
(output to file). Currently builtin formatters are `progress`, `documentation`,
`tap`, `junit`, `null`, `debug`.

### Ranges / Filters

You can execute specified spec only. It can be specified by line number,
example id, example name, tag and focues. To focus, prepend `f` to
groups / examples in specfiles. (e.g. `Describe` -> `fDescribe`, `It` -> `fIt`)

### Coverage

shellspec is integrated with coverage for ease of use. It works with the default
settings, but you may need to adjust options to make it more accurate.

[kcov](https://github.com/SimonKagstrom/kcov) is required to use coverage.

* How to [install kcov](https://github.com/SimonKagstrom/kcov/blob/master/INSTALL.md).
* Sample of [coverage report](https://circleci.com/api/v1.1/project/github/shellspec/shellspec/latest/artifacts/0/root/shellspec/coverage/index.html).

**Be aware of the shell can be used for coverage is `bash` only.**

### Profiler

When specified `--profile` option, profiler is enabled and list the slow examples.

### Task runner

You can run the task with `--task` option.

## Project directory

Typical directory structure.

```
Project directory
├─ .shellspec
├─ .shellspec-local
├─ report/
├─ coverage/
│
├─ bin/
│   ├─ executable_shell_script
│              :
├─ lib/
│   ├─ your_shell_script_library.sh
│              :
├─ libexec/
│   ├─ executable_utilities
│              :
├─ spec/
│   ├─ banner
│   ├─ spec_helper.sh
│   ├─ support/
│   ├─ your_shell_script_library_spec.sh
│              :
```

### .shellspec

Project default options for `shellspec` command.

### .shellspec-local

Override project default options (Do not store in VCS such as git).

### report/

Directory where the generator outputs reports.

### coverage/

Directory where the kcov outputs coverge.

### spec/

Directory where you create specfiles.

### banner

If exists `spec/banner` file, shows banner when `shellspec` command executed.
To disable shows banner with `--no-banner` option.

### spec_helper.sh

The *spec_helper.sh* loaded by `--require spec_helper` option.
This file use to preparation for running examples, define custom matchers, and etc.

### support/

This directory use to create file for custom matchers, tasks and etc.

## Specfile

### Example

**The best place to learn how to write specfile is [sample/spec](/sample/spec) directory. You must see it!**
*(Those samples includes failure examples on purpose.)*

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

The specfile is a valid shell script syntax, but performs translation process
to implements the scope and line number etc. Each example group block and
example block are translate to subsshell. Therefore changes inside the block
do not affect the outside of the block. In other words it realize local
variables and local functions in the specfile. This is very useful for
describing a structured spec. If you are interested in how to translate,
use the `--translate` option.

### DSL

#### Describe, Context - example group

You can write structured *example* using by `Describe`, `Context` block.
Example groups can be nested. Example groups can contain example groups or examples.
Each example groups run in subshell.

#### It, Example, Specify, Todo - example

You can write describe how code behaves using by `It`, `Example`, `Specify` block.
It constitute by maximum of one evaluation and multiple expectations.
`Todo` is one liner empty example.

#### When - evaluation

Defines the action for verification. The evaluation is start with `When`
It can be defined evaluation up to one for each example.

```
When call echo hello world
 |    |    |
 |    |    +-- The rest is action for verification
 |    +-- The evaluation type `call` is call a function or external command.
 +-- The evaluation is start with `When`
```

#### The - expectation

Defines the verification. The expectation is start with `The`

Verify the *subject* with the *matcher*.

```
The output should equal 4
 |    |           |
 |    |           +-- The `equal` matcher verify a subject is expected value 4.
 |    +-- The `output` subject uses the stdout as a subject for verification.
 +-- The expectation is start with `The`
```

You can reverses the verification with *should not*.

```
The output should not equal 4
```

You can use the *modifier* to modify the *subject*.

```
The line 2 of output should equal 4
    |
    +-- The `line` modifier use specified line 2 of output as subject.
```

The *modifier* is chainable.

```
The word 1 of line 2 of output should equal 4
```

You can use ordinal numbers.

```
The second line of output should equal 4
```


shellspec supports to improve readability *language chains* like chai.js.
It is only improve readability, does not any effect the expectation.

* a
* an
* as
* the

The following two sentences are the same meaning.

```
The first word of second line of output should valid number
```

```
The first word of the second line of output should valid as a number
```

#### Skip, Pending - skip and pending example

You can skip example by `Skip`. If you want to skip only in some cases,
use conditional skip `Skip if`. You can also use `Pending` to indicate the
to be implementation. You can temporary skip `Describe`, `Context`, `Example`,
`Specify`, `It` block. To skip, add prefixing `x` and modify to `xDescribe`,
`xContext`, `xExample`, `xSpecify`, `xIt`.

#### Include - include shell script

Include the shell script file to test.

#### Set - set shell option

Set shell option before execute each example.
The shell option name is the long name of `set` or the name of `shopt`.

e.g.

```sh
Set 'errexit:off' 'noglob:on'
```

#### Path, File, Dir - path alias

*TODO*

#### Data - input data for evaluation

You can use Data Helper that input data from stdin for evaluation.
After `#|` in the `Data` block is the input data.

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

#### subject, modifier, matcher

There is more *subject*, *modifier*, *matcher*. please refer to the
[References](/docs/references.md)

*Custom matcher*

shellspec has extensible architecture. So you can create custom matcher,
custom modifier, custom formatter, etc...

see [sample/spec/support/custom_matcher.sh](sample/spec/support/custom_matcher.sh) for custom matcher.

### Hooks

#### Before, After - example hook

You can define before / after hooks by `Before`, `After`.
The hooks are called for each example.

#### BeforeCall, AfterCall - call evaluation hook

You can define before / after call hooks by `BeforeCall`, `AfterCall`.
The hooks are called for before or after "call evaluation".

#### BeforeRun, AfterRun - run evaluation hook

You can define before / after run hooks by `BeforeRun`, `AfterRun`.
The hooks are called for before or after "run evaluation".

These hooks are executed in the same subshell as "run evaluation". So you can
mock/stub the function before run. And you can accessing variable for
evaluation after run.

### Directive

#### %const (%) - constant definition

`%const` (`%` is short hand) directive is define constant value. The characters
that can be used for variable name is upper capital, number and underscore only.
It can not be define inside of the example group or the example.

The timing of evaluation of the value is the specfile translation process.
So you can access shellspec variables, but you can not access variable or
function in the specfile.

This feature assumed use with conditional skip. The conditional skip may runs
outside of the examples. As a result, sometime you may need variables defined
outside of the examples.

#### %text - embedded text

You can use `%text` directive instead of hard-to-use heredoc with indented code.
After `#|` is the input data.

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

`%puts` (put string) and `%putsn` (put string with newline) can be used instead of
(not portable) echo. Unlike echo, not interpret escape sequences all shells.
`%-` is an alias of `%puts`, `%=` is an alias of `%putsn`.

#### %logger

Output log to `$SHELLSPEC_LOGFILE` (default: `/dev/tty`) for debugging.

#### %data

See `Parameters`

### Mock and Stub

Currentry, shellspec is not provide any special function for mocking / stubbing.
But redefine shell function can override existing shell function or external
command. It can use as mocking / stubbing.

Remember to `Describe`, `Context`, `It`, `Example`, `Specify` block running in
subshell. When going out of the block restore redefined function.

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

### Testing a single file script.

Shell scripts are often made up of a single file. shellspec provides two ways
to test a single shell script.

#### Sourced Return

This is a method for testing functions defined in shell scripts. Loading a
script with `Include` defines a `__SOURCED__` variable. If the `__SOURCE__`
variable is defined, return in your shell script process.

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

This is a method to mock/stub functions and commands when executing shell scripts.
By placing intercept points in your script, you can call the hooks defined in specfile.

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

## For developers

If you want to know shellspec architecture and self test, see [CONTRIBUTING.md](CONTRIBUTING.md)

## Version history

See [Changelog](CHANGELOG.md)
