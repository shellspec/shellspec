# shellspec

BDD style unit testing framework for POSIX compliant shell script.

[![Travis CI](https://img.shields.io/travis/shellspec/shellspec/master.svg?label=TravisCI)](https://travis-ci.org/shellspec/shellspec)
[![Cirrus CI](https://img.shields.io/cirrus/github/shellspec/shellspec.svg?label=CirrusCI)](https://cirrus-ci.com/github/shellspec/shellspec)
[![Circle CI](https://img.shields.io/circleci/build/github/shellspec/shellspec.svg?label=CircleCI)](https://circleci.com/gh/shellspec/shellspec)
[![Kcov](https://img.shields.io/badge/dynamic/json.svg?label=kcov&query=percent_covered&suffix=%25&url=https%3A%2F%2Fcircleci.com%2Fapi%2Fv1.1%2Fproject%2Fgithub%2Fshellspec%2Fshellspec%2Flatest%2Fartifacts%2F0%2Froot%2Fshellspec%2Fcoverage%2Fcoverage.json)](https://circleci.com/api/v1.1/project/github/shellspec/shellspec/latest/artifacts/0/root/shellspec/coverage/index.html)
[![Coveralls](https://img.shields.io/coveralls/github/shellspec/shellspec.svg?label=coveralls)](https://coveralls.io/github/shellspec/shellspec?branch=master)
[![Codecov](https://img.shields.io/codecov/c/github/shellspec/shellspec.svg?label=codecov)](https://codecov.io/gh/shellspec/shellspec)
[![CodeFactor](https://www.codefactor.io/repository/github/shellspec/shellspec/badge)](https://www.codefactor.io/repository/github/shellspec/shellspec)
[![GitHub top language](https://img.shields.io/github/languages/top/shellspec/shellspec.svg)](https://github.com/shellspec/shellspec/search?l=Shell)
[![GitHub release](https://img.shields.io/github/release/shellspec/shellspec.svg)](https://github.com/shellspec/shellspec/releases/latest)
[![License](https://img.shields.io/github/license/shellspec/shellspec.svg)](https://github.com/shellspec/shellspec/blob/master/LICENSE)

![bash](https://img.shields.io/badge/bash-%3E%3D2.03-lightgrey.svg?style=plastic)
![busybox](https://img.shields.io/badge/busybox-%3E%3D1.1.3-lightgrey.svg?style=plastic)
![dash](https://img.shields.io/badge/dash-%3E%3D0.5.2-lightgrey.svg?style=plastic)
![ksh](https://img.shields.io/badge/ksh-%3E%3D93q-lightgrey.svg?style=plastic)
![mksh](https://img.shields.io/badge/mksh-%3E%3D28-lightgrey.svg?style=plastic)
![posh](https://img.shields.io/badge/posh-%3E%3D0.3.14-lightgrey.svg?style=plastic)
![yash](https://img.shields.io/badge/yash-%3E%3D2.30-lightgrey.svg?style=plastic)
![zsh](https://img.shields.io/badge/zsh-%3E%3D3.1.9-lightgrey.svg?style=plastic)

**Let’s test the your shell script!**

![demo](demo.gif)

**Project status: Implementation of practical features has been completed. I will add more tests and improve the documentation.**

*Table of Contents*

- [Introduction](#Introduction)
  - [Features](#Features)
  - [Supported shells](#Supported-shells)
  - [Requires](#Requires)
- [Tutorial](#Tutorial)
  - [Installation](#Installation)
  - [Getting started](#Getting-started)
- [shellspec command](#shellspec-command)
  - [Usage](#Usage)
  - [Configure default options](#Configure-default-options)
  - [Special environment variable](#Special-environment-variable)
  - [Parallel execution](#Parallel-execution)
  - [Random execution](#Random-execution)
  - [Reporter / Generator](#Reporter--Generator)
  - [Ranges / Filters](#Ranges--Filters)
  - [Coverage](#Coverage)
  - [Task runner](#Task-runner)
- [Project directory](#Project-directory)
  - [.shellspec](#shellspec)
  - [.shellspec-local](#shellspec-local)
  - [report/](#report)
  - [coverage/](#coverage)
  - [spec/](#spec)
  - [banner](#banner)
  - [spec_helper.sh](#spechelpersh)
  - [support/](#support)
- [Specfile](#Specfile)
  - [Example](#Example)
  - [Translation process](#Translation-process)
  - [DSL](#DSL)
    - [Describe / Context (example group)](#Describe--Context-example-group)
    - [It / Example / Specify (example)](#It--Example--Specify-example)
    - [When (evaluation)](#When-evaluation)
    - [The (expectation)](#The-expectation)
    - [Skip / Pending](#Skip--Pending)
    - [Before / After (hook)](#Before--After-hook)
    - [Data (input for evaluation)](#Data-input-for-evaluation)
    - [subject / modifier / matcher](#subject--modifier--matcher)
  - [Directive](#Directive)
    - [%const (constant definition)](#const-constant-definition)
    - [%text (embedded text)](#text-embedded-text)
    - [%puts / %putsn (output)](#puts--putsn-output)
    - [%logger](#logger)
  - [Mock and Stub](#Mock-and-Stub)
- [Version history](#Version-history)

## Introduction

### Features

* Support POSIX compliant shell (dash, bash, ksh, busybox, etc...)
* BDD style specfile syntax
* The specfile is compatible with shell script syntax
* Implemented by shell script
* Minimal dependencies (use only a few basic POSIX compliant command)
* Nestable block with scope like lexical scope
* Mocking and stubbing (temporary function override)
* Parallel execution, random ordering execution
* Filtering (line number, id, focus, tag and example name)
* The hook before and after of the examples
* Skip and pending of the examples
* Useful and portability standard input / output directive for testing
* Modern reporting (colorize, failure line number)
* Coverage ([kcov](http://simonkagstrom.github.io/kcov/index.html) integration, requires kcov and bash)
* Built-in simple task runner
* Extensible architecture (custom matcher, custom formatter, etc...)
* shellspec is tested by shellspec

### Supported shells

`dash`, `bash`, `ksh`, `mksh`, `oksh`, `pdksh`, `zsh`, `posh`, `yash`, `busybox (ash)`, `bosh`, `pbosh`

Tested Platforms (See tested shells [.travis.yml](.travis.yml), [.cirrus.yml](.cirrus.yml))

| Platform                                                  | Test                                                          |
| --------------------------------------------------------- | ------------------------------------------------------------- |
| Ubuntu 12.04, 14.04, 16.04, 18.04                         | [Travis CI](https://travis-ci.org/shellspec/shellspec)        |
| macOS 10.10, 10.11, 10.12, 10.13, 10.14, 10.14 (Homebrew) | [Travis CI](https://travis-ci.org/shellspec/shellspec)        |
| FreeBSD 10.x, 11.x, 12.x                                  | [Cirrus CI](https://cirrus-ci.com/github/shellspec/shellspec) |
| Windows Server 2019 (Git bash, msys2, cygwin)             | [Cirrus CI](https://cirrus-ci.com/github/shellspec/shellspec) |
| Windows 10 1903 (Ubuntu 18.04 on WSL)                     | manual                                                        |
| Solaris 11                                                | manual                                                        |

<details>
<summary>Tested shell and version (tested with docker)</summary>

| Platform       | ash   | bash  | busybox    | dash     | ksh | mksh | pdksh  | posh   | yash | zsh    |
| -------------- | ----- | ----- | ---------- | -------- | --- | ---- | ------ | ------ | ---- | ------ |
| alpine latest  |       |       | 1.29.3     |          |     |      |        |        |      |        |
| alpine edge    |       |       | 1.30.1     |          |     |      |        |        |      |        |
| busybox        |       |       | 1.30.1     |          |     |      |        |        |      |        |
| debian 2.2     |       | 2.03  |            |          |     |      | 5.2.14 |        |      | 3.1.9  |
| debian 3.0     | 0.3.8 | 2.05a | ~~0.60.2~~ |          |     |      | 5.2.14 |        |      | 4.0.4  |
| debian 3.1     |       | 2.05b | ~~0.60.5~~ | 0.5.2    | 93q |      | 5.2.14 | 0.3.14 |      | 4.2.5  |
| debian 4.0     |       | 3.1   | 1.1.3      | 0.5.3    | 93r | 28   | 5.2.14 | 0.5.4  |      | 4.3.2  |
| debian 5.0     |       | 3.2   | 1.10.2     | 0.5.4    | 93s | 35.2 | 5.2.14 | 0.6.13 |      | 4.3.6  |
| debian 6       |       | 4.1.5 | 1.17.1     | 0.5.5.1  | 93s | 39   | 5.2.14 | 0.8.5  |      | 4.3.10 |
| debian 7       |       | 4.2   | 1.20.0     | 0.5.7    | 93u | 40.9 |        | 0.10.2 | 2.30 | 4.3.17 |
| debian 8       |       | 4.3   | 1.22.0     | 0.5.7    | 93u | 50d  |        | 0.12.3 | 2.36 | 5.0.7  |
| debian 9       |       | 4.4   | 1.22.0     | 0.5.8    | 93u | 54   |        | 0.12.6 | 2.43 | 5.3.1  |
| debian buster  |       | 5.0.4 | 1.30.1     | 0.5.10.2 | 93u | 57   |        | 0.13.2 | 2.48 | 5.7.1  |
| Ubuntu 16.04   |       |       |            |          |     | 52c  |        |        |      | 5.1.1  |
| Ubuntu 18.04   |       |       | 1.27.2     |          |     | 56c  |        | 0.13.1 |      | 5.4.2  |
| Ubuntu 19.04   |       |       |            |          |     |      |        |        |      | 5.5.1  |

* **The version of strikethrough is does NOT work**
* I confirmed that works with [Schily Bourne Shell](http://schilytools.sourceforge.net/bosh.html) (`bosh`, `pbosh`) linux build, but not well tested.
* If you want to do the tests above, run `./contrib/test_in_docker.sh <DOCKERFILES...> [-- COMMAND]`. ([Dockerfiles](dockerfiles))

</details>

### Requires

shellspec is implemented in a pure shell script, so what you need is the target shell
and few basic POSIX compliant command (except `kcov` for optionally coverage).

Currently used external command:

`date`, `ls`, `mkdir`, `rm`, `printf`, `sleep`, `sort`, `od` (recommends: `ps`, `time`)

## Tutorial

### Installation

**Just get the shellspec and create a symlink in your executable PATH!**

From git

```sh
$ cd /SOME/WHERE/TO/INSTALL
$ git clone https://github.com/shellspec/shellspec.git
$ ln -s /SOME/WHERE/TO/INSTALL/shellspec/shellspec /EXECUTABLE/PATH/
# (e.g. /EXECUTABLE/PATH/ = /usr/local/bin/, $HOME/bin/)
```

From tar.gz

```sh
$ cd /SOME/WHERE/TO/INSTALL
$ wget https://github.com/shellspec/shellspec/archive/{VERSION}.tar.gz
$ tar xzvf shellspec-{VERSION}.tar.gz

$ ln -s /SOME/WHERE/TO/INSTALL/shellspec-{VERSION}/shellspec /EXECUTABLE/PATH/
# (e.g. /EXECUTABLE/PATH/ = /usr/local/bin/, $HOME/bin/)
```

If you can't create symlink (like default of Git for Windows), create the `shellspec` file.

```sh
$ cat<<'HERE'>/EXECUTABLE/PATH/shellspec
#!/bin/sh
exec /SOME/WHERE/TO/INSTALL/shellspec/shellspec "$@"
HERE
$ chmod +x /EXECUTABLE/PATH/shellspec
```

### Getting started

**Just create your project directory and run `shellspec --init` to setup to your project**

```sh
# Create your project directory
$ mkdir <your-project-directory>
$ cd <your-project-directory>

# Initialize
$ shellspec --init
  create .shellspec
  create spec/spec_helper.sh

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

  **** Output ****

      --[no-]banner                   Show banner if exist 'spec/banner' [default: enabled]
  -f, --format FORMATTER              Choose a formatter to use for display
                                        [p]rogress      dots [default]
                                        [d]ocumentation group and example names
                                        [t]ap           TAP format
                                        [j]unit         JUnit XML
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
                                        --include-path=.
                                        --include-pattern=.sh
                                        --exclude-pattern=/coverage/,/spec/,/report/
      --kcov-options KOPTIONS         Specify additional kcov options

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

You can use parallel execution for fast test with `--jobs` option.

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

shellspec is integrated with coverage for ease of use
(Requires to [install kcov](https://github.com/SimonKagstrom/kcov)).
It works with the default settings, but you may need to adjust kcov's options
to make it more accurate. Be aware of the shell can be used for coverage
is `bash` only.

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

**The best place to learn how to write specfile is [sample/spec](/sample/spec) directory. You must see it!** *(Those samples includes failure examples on purpose.)*

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

#### Describe / Context (example group)

You can write structured *example* using by `Describe`, `Context`. Example
groups can be nested. Example groups can contain example groups or examples.
Each example groups run in subshell.

#### It / Example / Specify (example)

You can write describe how code behaves using by `It`, `Example`, `Specify`.
It constitute by maximum of one evaluation and multiple expectations.

#### When (evaluation)

Defines the action for verification. The evaluation is start with `When`
It can be defined evaluation up to one for each example.

```
When call echo hello world
 |    |    |
 |    |    +-- The rest is action for verification
 |    +-- The evaluation type `call` is call a function or external command.
 +-- The evaluation is start with `When`
```

#### The (expectation)

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

#### Skip / Pending

You can skip example by `Skip`. If you want to skip only in some cases,
use conditional skip `Skip if`. You can also use `Pending` to indicate the
to be implementation. You can temporary skip `Describe`, `Context`, `Example`,
`Specify`, `It` block. To skip, add prefixing `x` and modify to `xDescribe`,
`xContext`, `xExample`, `xSpecify`, `xIt`.

#### Before / After (hook)

You can define hooks called before/after running example by `Before`, `After`.
The hook is called for each example.

#### Data (input for evaluation)

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

#### subject / modifier / matcher

There is more *subject*, *modifier*, *matcher*. please refer to the
[References](/References.md)

*Custom matcher*

shellspec has extensible architecture. So you can create custom matcher,
custom modifier, custom formatter, etc...

see [sample/spec/support/custom_matcher.sh](sample/spec/support/custom_matcher.sh) for custom matcher.

### Directive

#### %const (constant definition)

`%const` (`%` is short hand) directive is define constant value. The characters
that can be used for variable name is upper capital, number and underscore only.
It can not be define inside of the example group or the example.

The timing of evaluation of the value is the specfile translation process.
So you can access shellspec variables, but you can not access variable or
function in the specfile.

This feature assumed use with conditional skip. The conditional skip may runs
outside of the examples. As a result, sometime you may need variables defined
outside of the examples.

#### %text (embedded text)

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

#### %puts / %putsn (output)

`%puts` (put string) and `%putsn` (put string with newline) can be used instead of
(not portable) echo. Unlike echo, not interpret escape sequences all shells.
`%-` is an alias of `%puts`, `%=` is an alias of `%putsn`.

#### %logger

Output log to `$SHELLSPEC_LOGFILE` (default: `/dev/tty`) for debugging.

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

## Version history

See [Changelog](CHANGELOG.md)
