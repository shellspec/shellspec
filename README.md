# shellspec

BDD style unit testing framework for POSIX compatible shell script.

[![Build Status](https://travis-ci.org/ko1nksm/shellspec.svg?branch=master)](https://travis-ci.org/ko1nksm/shellspec)

**Let’s test the your shell script!**

![demo](demo.gif)

*Table of Contents*

- [Introduction](#introduction)
  - [Features](#features)
  - [Supported shells](#supported-shells)
  - [Requires](#requires)
- [Tutorial](#tutorial)
  - [Installation](#installation)
  - [Getting started](#getting-started)
- [Usage](#usage)
- [Specfile DSL](#specfile-dsl)
  - [Syntax example](#syntax-example)
  - [Samples](#samples)
  - [Example group (Describe/Context)](#example-group-describecontext)
  - [Example (Example/Specify/It)](#example-examplespecifyit)
    - [Evaluation (When)](#evaluation-when)
    - [Expectation (The)](#expectation-the)
  - [Helper](#helper)
    - [Skip and pending (Skip/Pending)](#skip-and-pending-skippending)
    - [Before and after hook (Before/After)](#before-and-after-hook-beforeafter)
    - [Input from stdin (Data)](#input-from-stdin-data)
  - [Mock and Stub](#mock-and-stub)
  - [Directive](#directive)
    - [Constant definition (%const)](#constant-definition-const)
    - [Embedded text (%text)](#embedded-text-text)
  - [More syntax (subject/modifier/matcher/etc.)](#more-syntax-subjectmodifiermatcheretc)
  - [Custom matcher](#custom-matcher)
- [shellspec command](#shellspec-command)
  - [Configure default options](#configure-default-options)
  - [Task runner](#task-runner)
- [spec directory](#spec-directory)
  - [spec_helper.sh](#spechelpersh)
  - [support](#support)
  - [banner](#banner)
- [Version history](#version-history)

## Introduction

### Features

* Support POSIX compatible shell (dash, bash, ksh, busybox, etc...)
* BDD style syntax
* The specfile is a valid shell script language syntax
* Pure shell script implementation
* Minimum Dependencies (Use only a few POSIX compliant command)
* Parallel execution
* Filtering (Running by line number and focused groups /examples)
* Nestable groups with scope like lexical scope
* Before / After hooks
* Skip / Pending
* Data helper that easy to input from stdin
* Embedded text that easier to use than heredoc at indented code
* Mocking and stubbing (temporary function override)
* Built-in simple task runner
* Modern reporting (colorize, failure line number)
* Extensible architecture (custom matcher, custom formatter, etc...)
* shellspec is tested by shellspec

### Supported shells

`dash`, `bash`, `ksh`, `mksh`, `pdksh`, `zsh`, `posh`, `yash`, `busybox (ash)`

Tested Platforms

| Platform                              | Test   | Shells                                            |
| ------------------------------------- | ------ | ------------------------------------------------- |
| Ubuntu 16.04 xenial                   | CI     | bash, busybox, dash, ksh93, mksh, posh, yash, zsh |
| macOS 10.4 Mojave                     | CI     | bash, dash, ksh93, mksh, ~~posh~~, yash, zsh      |
| macOS 10.4 Mojave                     | manual | bash, dash, ksh93, mksh, ~~posh~~, yash, zsh      |
| Windows 10 1809 (Ubuntu 18.04 on WSL) | manual | bash, busybox, dash, ksh93, mksh, posh, yash, zsh |
| Solaris 11                            | manual | ~~Bourne Shell~~, ksh88, ksh93                    |

Confirmed version (tested with docker [contrib/dockerfiles](/contrib/dockerfiles))

| Platform      | ash   | bash  | busybox    | dash     | ksh | mksh | pdksh  | posh   | yash | zsh    |
| ------------- | ----- | ----- | ---------- | -------- | --- | ---- | ------ | ------ | ---- | ------ |
| alpine latest |       |       | 1.29.3     |          |     |      |        |        |      |        |
| alpine edge   |       |       | 1.30.1     |          |     |      |        |        |      |        |
| busybox       |       |       | 1.30.1     |          |     |      |        |        |      |        |
| debian 2.2    |       | 2.03  |            |          |     |      | 5.2.14 |        |      | 3.1.9  |
| debian 3.0    | 0.3.8 | 2.05a | ~~0.60.2~~ |          |     |      | 5.2.14 |        |      | 4.0.4  |
| debian 3.1    |       | 2.05b | ~~0.60.5~~ | 0.5.2    | 93q |      | 5.2.14 | 0.3.14 |      | 4.2.5  |
| debian 4.0    |       | 3.1   | 1.1.3      | 0.5.3    | 93r | 28   | 5.2.14 | 0.5.4  |      | 4.3.2  |
| debian 5.0    |       | 3.2   | 1.10.2     | 0.5.4    | 93s | 35.2 | 5.2.14 | 0.6.13 |      | 4.3.6  |
| debian 6      |       | 4.1.5 | 1.17.1     | 0.5.5.1  | 93s | 39   | 5.2.14 | 0.8.5  |      | 4.3.10 |
| debian 7      |       | 4.2   | 1.20.0     | 0.5.7    | 93u | 40.9 |        | 0.10.2 | 2.30 | 4.3.17 |
| debian 8      |       | 4.3   | 1.22.0     | 0.5.7    | 93u | 50d  |        | 0.12.3 | 2.36 | 5.0.7  |
| debian 9      |       | 4.4   | 1.22.0     | 0.5.8    | 93u | 54   |        | 0.12.6 | 2.43 | 5.3.1  |
| debian buster |       | 5.0.2 | 1.30.1     | 0.5.10.2 | 93u | 57   |        | 0.13.2 | 2.48 | 5.7.1  |

**The version of strikethrough is does NOT work**

### Requires

shellspec is implemented in a pure shell script, so what you need is
the target shell and few POSIX compliant command.

Currently used external command:

`date`, `mkdir`, `rm`, `mv`, `cat` (recommends: `printf`, `ps`, `readlink`, `time`)

## Tutorial

### Installation

**Just get the shellspec and create a symlink in your executable PATH!**

From git

```sh
$ cd /SOME/WHERE/TO/INSTALL
$ git clone https://github.com/ko1nksm/shellspec.git
$ ln -s /SOME/WHERE/TO/INSTALL/shellspec/shellspec /EXECUTABLE/PATH/
# (e.g. /EXECUTABLE/PATH/ = /usr/local/bin/, $HOME/bin/)
```

From tar.gz

```sh
$ cd /SOME/WHERE/TO/INSTALL
$ wget https://github.com/ko1nksm/shellspec/archive/{VERSION}.tar.gz
$ tar xzvf shellspec-{VERSION}.tar.gz

$ ln -s /SOME/WHERE/TO/INSTALL/shellspec-{VERSION}/shellspec /EXECUTABLE/PATH/
# (e.g. /EXECUTABLE/PATH/ = /usr/local/bin/, $HOME/bin/)
```

If does not installed `readlink`, create `shellspec` file.

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

## Usage

```
Usage: shellspec [options] [files or directories]

  -s, --shell SHELL                   Specify a path of shell [default: current shell]
      --[no-]fail-fast[=COUNT]        Abort the run after a certain number of failures [default: 1]
  -e, --env NAME=VALUE                Set environment variable
  -w, --warnings LEVEL                Set warnings level
                                        none (do not show warnings)
                                        notice (show warnings but not treats as error)
                                        error (show warnings and treats as error) [default]
                                        failure (treats warnings as failures)
  -j, --jobs JOBS                     Number of parallel jobs to run (0 jobs means disabled)
      --count                         Count the number of examples without running any examples
      --syntax-check                  Syntax check of the specfiles without running any examples
      --dry-run                       Print the formatter output without running any examples

  **** Output ****

      --[no-]banner                   Show banner if exist 'spec/banner' [default: enabled]
  -f, --format FORMATTER              Choose a formatter.
                                        [p]rogress (dots) [default]
                                        [d]ocumentation (group and example names)
                                        [t]ap
                                        debug (for developer)
                                        custom formatter name
      --force-color, --force-colour   Force the output to be in color, even if the output is not a TTY
      --no-color, --no-colour         Force the output to not be in color, even if the output is a TTY
      --skip-message VERBOSE          Mute skip message
                                        none (do not mute any messages) [default]
                                        moderate (mute repeated messages)
                                        quiet (mute repeated messages and non-temporarily messages)

  **** Filtering ****

    You can select examples by appending the line numbers to the filename

      e.g. shellspec path/to/a_spec.sh:10:20

      --focus                         Run focused groups / examples only
                                        To focus, prepend 'f' to groups / examples in specfiles
                                        e.g. Describe -> fDescribe, It -> fIt

  **** Utility ****

      --init                          Initialize your project with shellspec
      --task [TASK]                   Run task. If TASK is not specified, show the task list
      --translate                     Output translated specfile
  -v, --version                       Display the version
  -h, --help                          You're looking at it
  ```


## Specfile DSL

### Syntax example

```sh
Describe 'sample' # Example group
  Describe 'bc command'
    add() { echo "$1 + $2" | bc; }

    It 'performs addition' # Example
      When call add 2 3 # Evaluation
      The output should eq 5  # Expectation
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

The specfile is a valid shell script syntax, but performs translation process
to implements the scope and line number etc.

The each example group block and the example block are translate to subsshell.
Therefore changes inside the block do not affect the outside of the block.

In other words it realize local variables and local functions in the specfile.
This is very useful for describing a structured spec.

If you are interested in how to translate, use the `--translate` option.

### Samples

**The best place to learn DSL is [sample/spec](/sample/spec) directory. You must see it!**

*Be ware that those specfiles includes failure examples.*

### Example group (Describe/Context)

You can write structured *example* using by `Describe`, `Context`. Example
groups can be nested. Example groups can contain example groups or examples.
Each example groups run in subshell.

### Example (Example/Specify/It)

You can write describe how code behaves using by `Example`, `Specify`, `It`.
It constitute by maximum of one *Evaluation* and multiple *Expectations*.

#### Evaluation (When)

Defines the action for verification. The evaluation is start with `When`
It can be defined `Evaluation` up to one for each `Example`.

```
When call echo hello world
 |    |    |
 |    |    +-- The rest is action for verification
 |    +-- The evaluation type `call` is call a function or external command.
 +-- The evaluation is start with `When`
```

#### Expectation (The)

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

### Helper

#### Skip and pending (Skip/Pending)

You can skip example by `Skip`. If you want to skip only in some cases,
use conditional skip `Skip if`.

You can also use `Pending` to indicate the to be implementation.

You can temporary skip `Describe`, `Context`, `Example`, `Specify`, `It` block.
To skip, add prefixing `x` and modify to `xDescribe`, `xContext`, `xExample`,
`xSpecify`, `xIt`.

#### Before and after hook (Before/After)

You can define hooks called before/after running example by `Before`, `After`.
The hook is called for each example.

#### Input from stdin (Data)

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

### Mock and Stub

Currentry, shellspec is not provide any special function for mocking/stubbing.
But redefine shell function can override existing shell function or external
command. It can use as mocking/stubbing.

Remember to `Describe`, `Context`, `Example`, `Specify`, `It` block running in
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

### Directive

#### Constant definition (%const)

`%const` (`%` is short hand) directive is define constant value. The characters
that can be used for variable name is upper capital, number and underscore only.
It can not be define inside of the example group or the example.

The timing of evaluation of the value is the specfile translation process.
So you can access shellspec variables, but you can not access variable or
function in the specfile.

This feature assumed use with conditional skip. The conditional skip may runs
outside of the examples. As a result, sometime you may need variables defined
outside of the examples.

#### Embedded text (%text)

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

    heredoc_breaks_indent() {
      echo "start"
      cat<<'HERE'
aaa
bbb
ccc
HERE
      echo "end"
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

### More syntax (subject/modifier/matcher/etc.)

There is more *subject*, *modifier*, *matcher*. please refer to the
[References](/References.md)

### Custom matcher

shellspec has extensible architecture. So you can create custom matcher,
custom modifier, custom formatter, etc...

see [sample/spec/support/custom_matcher.sh](sample/spec/support/custom_matcher.sh) for custom matcher.

## shellspec command

### Configure default options

To change default options for `shellspec` command, create options file.
Read files in the order the bellows and overrides options.

1. `$XDG_CONFIG_HOME/shellspec/options`
2. `$HOME/.shellspec`
3. `./.shellspec`
4. `./.shellspec-local` (Do not manage by VCS)

### Task runner

You can run the task with `--task` option.

## spec directory

### spec_helper.sh

The *spec_helper.sh* loaded by `--require spec_helper` option.

This file use to preparation for running examples, define custom matchers, and etc.

### support

This directory use to create file for custom matchers, tasks and etc.

### banner

If exists `spec/banner` file, shows banner when `shellspec` command executed.
To disable shows banner with `--no-banner` option.


## Version history

0.11.0 (2019-04-20)

* Run the example by line number. (`*_spec.sh:#`)
* Run focused groups / examples. (`fDescribe`, `fContext`, `fExample`, `fSpecify`, `fIt`)
* Add `--count` option for count the number of examples without running.

0.10.0 (2019-04-17)

* Remove `Def` helper. (use `%putsn`, `%puts` directive instead)
* Support parallel execution. (`--jobs` option)
* Separete syntax checker into tools.
* Improve syntax checker.
* Improve error handling.
* Improve ctrl-c handling.

0.9.0 (2019-03-30)

* Remove shorthand of the variable subject.
* Change timing of loading external script by 'Include'. [breaking change]
* Fix for translation speed slowdown.
* Add `--syntax-check` option for syntax check of the specfile.

0.8.0 (2019-03-26)

* Remove `It` statement and change `It` is alias of `Example` now.
* Remove `Set` / `Unset` helper.
* Remove `Debug` helper.
* Remove `string` subject.
* Remove `exit status` subject. (use `status` subject)
* Change behavior of `line` and `lines` modifier to like "grep -c" not "wc -l".
* Change `function` subject to alias for `value` subject.
* Improve handling unexpected errors.
* Improve samples.
* Add `Constant definition`.
* Add `Data` helper, `Embedded text`.
* Add `Def` helper.
* Add `Logger` helper.
* Add `result` modifier.
* Add `Include` helper.
* Add shorthand for `function` subject and `variable` subject.
* Add failed message for `Before`/`After` each hook.

0.7.0 (2019-03-08)

* Added `lines` modifier.

0.6.0 (2019-02-19)

* Added `match` matcher.

0.5.0 (2019-02-06)

* Initial public release.
