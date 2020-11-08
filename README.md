# ShellSpec

ShellSpec is a **full-featured BDD unit testing framework** for dash, bash, ksh, zsh and **all POSIX shells** that provides first-class features such as code coverage, mocking, parameterized test, parallel execution and more. It was developed as a dev/test tool for **cross-platform shell scripts and shell script libraries**. ShellSpec is a new modern testing framework released in 2019, but it's already stable enough. With lots of practical CLI features and simple yet powerful syntax, it provides you with a fun shell script test environment.

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
[![busybox](https://img.shields.io/badge/busybox-&ge;1.20.0-lightgrey.svg?style=flat)](https://www.busybox.net/)
[![dash](https://img.shields.io/badge/dash-&ge;0.5.4-lightgrey.svg?style=flat)](http://gondor.apana.org.au/~herbert/dash/)
[![ksh](https://img.shields.io/badge/ksh-&ge;93s-lightgrey.svg?style=flat)](http://kornshell.org)
[![mksh](https://img.shields.io/badge/mksh-&ge;R28-lightgrey.svg?style=flat)](http://www.mirbsd.org/mksh.htm)
[![posh](https://img.shields.io/badge/posh-&ge;0.3.14-lightgrey.svg?style=flat)](https://salsa.debian.org/clint/posh)
[![yash](https://img.shields.io/badge/yash-&ge;2.29-lightgrey.svg?style=flat)](https://yash.osdn.jp/)
[![zsh](https://img.shields.io/badge/zsh-&ge;3.1.9-lightgrey.svg?style=flat)](https://www.zsh.org/)

----

**Thank you for your interest in ShellSpec. Please visit 🚩[the official website](https://shellspec.info/) to know the impressive features!**

Let's have fun testing your shell scripts! (Try [Online Demo](https://shellspec.info/demo) on your browser).

[![demo](docs/demo.gif)](https://shellspec.info/demo)

[![Coverage report](docs/coverage.png)](https://circleci.com/api/v1.1/project/github/shellspec/shellspec/latest/artifacts/0/coverage/index.html?branch=master)

**Latest Update.**

See [CHANGELOG.md](CHANGELOG.md)

NOTE: This documentation contains unreleased features. Check them in the changelog.

----

## Table of Contents <!-- omit in toc -->

- [Supported shells and platforms](#supported-shells-and-platforms)
- [Requirements](#requirements)
- [Installation](#installation)
- [Tutorial](#tutorial)
- [ShellSpec CLI](#shellspec-cli)
- [Project directory structure](#project-directory-structure)
- [Specfile (test file)](#specfile-test-file)
  - [Embedded shell scripts](#embedded-shell-scripts)
  - [Sample](#sample)
- [DSL syntax](#dsl-syntax)
  - [Basic structure](#basic-structure)
    - [`Describe`, `Context`, `ExampleGroup` - example group block](#describe-context-examplegroup---example-group-block)
    - [`It`, `Specify`, `Example` - example block](#it-specify-example---example-block)
    - [`Todo` - one liner empty example](#todo---one-liner-empty-example)
    - [`When` - evaluation](#when---evaluation)
      - [`call` - call a shell function (without subshell)](#call---call-a-shell-function-without-subshell)
      - [`run` - run a command (within subshell)](#run---run-a-command-within-subshell)
        - [`command` - runs a external command](#command---runs-a-external-command)
        - [`script` - runs a shell script](#script---runs-a-shell-script)
        - [`source` - runs a script by `.` (dot) command](#source---runs-a-script-by--dot-command)
      - [About executing aliases](#about-executing-aliases)
    - [`The` - expectation](#the---expectation)
      - [Subjects](#subjects)
      - [Modifiers](#modifiers)
      - [Matchers](#matchers)
      - [Language chains](#language-chains)
    - [`Assert` - expectation for custom assertion](#assert---expectation-for-custom-assertion)
  - [Pending, skip and focus](#pending-skip-and-focus)
    - [`Pending` - pending example](#pending---pending-example)
    - [`Skip` - skip example](#skip---skip-example)
      - [`if` - conditional skip](#if---conditional-skip)
    - ['x' prefix for example group and example](#x-prefix-for-example-group-and-example)
      - [`xDescribe`, `xContext`, `xExampleGroup` - skipped example group](#xdescribe-xcontext-xexamplegroup---skipped-example-group)
      - [`xIt`, `xSpecify`, `xExample` - skipped example](#xit-xspecify-xexample---skipped-example)
    - ['f' prefix for example group and example](#f-prefix-for-example-group-and-example)
      - [`fDescribe`, `fContext`, `fExampleGroup` - focused example group](#fdescribe-fcontext-fexamplegroup---focused-example-group)
      - [`fIt`, `fSpecify`, `fExample` - focused example](#fit-fspecify-fexample---focused-example)
    - [About temporary pending and skip](#about-temporary-pending-and-skip)
  - [Hooks](#hooks)
    - [`BeforeEach` (`Before`), `AfterEach` (`After`) - example hook](#beforeeach-before-aftereach-after---example-hook)
    - [`BeforeAll`, `AfterAll` - example group hook](#beforeall-afterall---example-group-hook)
    - [`BeforeCall`, `AfterCall` - call evaluation hook](#beforecall-aftercall---call-evaluation-hook)
    - [`BeforeRun`, `AfterRun` - run evaluation hook](#beforerun-afterrun---run-evaluation-hook)
  - [Helpers](#helpers)
    - [`Dump` - dump stdout, stderr and status for debugging](#dump---dump-stdout-stderr-and-status-for-debugging)
    - [`Include` - include a script file](#include---include-a-script-file)
    - [`Set` - set shell option](#set---set-shell-option)
    - [`Path`, `File`, `Dir` - path alias](#path-file-dir---path-alias)
    - [`Data` - pass data as stdin to evaluation](#data---pass-data-as-stdin-to-evaluation)
    - [`Parameters` - parameterized example](#parameters---parameterized-example)
    - [`Mock` - create a command-based mock](#mock---create-a-command-based-mock)
    - [`Intercept` - create an intercept point](#intercept---create-an-intercept-point)
- [Directives](#directives)
  - [`%const` (`%`) - constant definition](#const----constant-definition)
  - [`%text` - embedded text](#text---embedded-text)
  - [`%puts` (`%-`), `%putsn` (`%=`) - output a string (with newline)](#puts---putsn----output-a-string-with-newline)
  - [`%printf` - alias for printf](#printf---alias-for-printf)
  - [`%sleep` - alias for sleep](#sleep---alias-for-sleep)
  - [`%preserve` - preserve variables](#preserve---preserve-variables)
  - [`%logger` - debug output](#logger---debug-output)
  - [`%data` - define parameter](#data---define-parameter)
- [Mocking](#mocking)
  - [Function-based mock](#function-based-mock)
  - [Command-based mock](#command-based-mock)
- [Support commands](#support-commands)
  - [Execute the actual command within a mock function](#execute-the-actual-command-within-a-mock-function)
  - [Make mock not mandatory in sandbox mode](#make-mock-not-mandatory-in-sandbox-mode)
  - [Resolve command incompatibilities](#resolve-command-incompatibilities)
- [Testing a single file script](#testing-a-single-file-script)
  - [Sourced Return](#sourced-return)
  - [Intercept](#intercept)
- [Self-executable specfile](#self-executable-specfile)
- [Use with Docker](#use-with-docker)
- [Extension](#extension)
  - [Custom subject, modifier and matcher](#custom-subject-modifier-and-matcher)
- [For developers](#for-developers)
  - [Subprojects](#subprojects)
    - [ShellMetrics - Cyclomatic Complexity Analyzer for shell scripts](#shellmetrics---cyclomatic-complexity-analyzer-for-shell-scripts)
    - [ShellBench - A benchmark utility for POSIX shell comparison](#shellbench---a-benchmark-utility-for-posix-shell-comparison)
  - [Related projects](#related-projects)
    - [getoptions - An elegant option parser and generator for shell scripts](#getoptions---an-elegant-option-parser-and-generator-for-shell-scripts)
    - [readlinkf - readlink -f implementation for shell scripts](#readlinkf---readlink--f-implementation-for-shell-scripts)
  - [Inspired frameworks](#inspired-frameworks)
  - [Contributions](#contributions)

## Supported shells and platforms

- <code>[bash][bash]</code>_>=2.03_, <code>[bosh/pbosh][bosh]</code>_>=2018/10/07_, <code>[posh][posh]</code>_>=0.3.14_, <code>[yash][yash]</code>_>=2.29_, <code>[zsh][zsh]</code>_>=3.1.9_
- <code>[dash][dash]</code>_>=0.5.4_, <code>[busybox][busybox] ash</code>_>=1.20.0_, <code>[busybox-w32][busybox-w32]</code>, <code>[GWSH][gwsh]</code>_>=20190627_
- <code>ksh88</code>, <code>[ksh93][ksh93]</code>_>=93s_, <code>[ksh2020][ksh2020]</code>, <code>[mksh/lksh][mksh]</code>_>=R28_, <code>[pdksh][pdksh]</code>_>=5.2.14_
- <code>[FreeBSD sh][freebsdsh]</code>, <code>[NetBSD sh][netbsdsh]</code>, <code>[OpenBSD ksh][openbsdksh]</code>, <code>[loksh][loksh]</code>, <code>[oksh][oksh]</code>

[bash]: https://www.gnu.org/software/bash/
[bosh]: http://schilytools.sourceforge.net/bosh.html
[busybox]: https://www.busybox.net/
[busybox-w32]: https://frippery.org/busybox/
[dash]: http://gondor.apana.org.au/~herbert/dash/
[gwsh]: https://github.com/hvdijk/gwsh
[ksh93]: http://kornshell.org
[ksh2020]: https://github.com/ksh-community/ksh
[mksh]: http://www.mirbsd.org/mksh.htm
[posh]: https://salsa.debian.org/clint/posh
[yash]: https://yash.osdn.jp/
[zsh]: https://www.zsh.org/
[netbsdsh]: http://cvsweb.netbsd.org/bsdweb.cgi/src/bin/sh/
[freebsdsh]: https://www.freebsd.org/cgi/man.cgi?sh(1)
[openbsdksh]: https://man.openbsd.org/ksh.1
[pdksh]: https://web.archive.org/web/20160918190548/http://www.cs.mun.ca:80/~michael/pdksh/
[loksh]: https://github.com/dimkr/loksh
[oksh]: https://github.com/ibara/oksh

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

## Requirements

### POSIX-compliant commands <!-- omit in toc -->

ShellSpec uses shell built-in commands and only few basic [POSIX-compliant commands][utilities] to
support widely environments (except `kcov` for optional code coverage).

[utilities]: http://pubs.opengroup.org/onlinepubs/9699919799/utilities/contents.html

Currently used external (not shell builtins) commands:

- `cat`, `date`, `env`, `ls`, `mkdir`, `od` (or not POSIX `hexdump`), `rm`, `sleep`, `sort`, `time`
- `ps` (use to auto-detect shells in environments that don't implement procfs)
- `ln`, `mv` (use only when generating coverage report)
- `kill`, `printf` (most shells except some are built-in)

## Installation

### Install the latest release version <!-- omit in toc -->

```sh
curl -fsSL https://git.io/shellspec | sh
```

or

```sh
wget -O- https://git.io/shellspec | sh
```

NOTE: `https://git.io/shellspec` is redirected to `https://github.com/shellspec/shellspec/raw/master/install.sh`

<details>
<summary>Advanced installation / upgrade / uninstall</summary>

### Automatic installation <!-- omit in toc -->

```sh
curl -fsSL https://git.io/shellspec | sh -s -- --yes
```

### Install the specified version <!-- omit in toc -->

```sh
curl -fsSL https://git.io/shellspec | sh -s 0.19.1
```

### Upgrade to the latest release version <!-- omit in toc -->

```sh
curl -fsSL https://git.io/shellspec | sh -s -- --switch
```

### Switch to the specified version <!-- omit in toc -->

```sh
curl -fsSL https://git.io/shellspec | sh -s 0.18.0 --switch
```

### How to uninstall <!-- omit in toc -->

1. Delete the ShellSpec executable file [default: `$HOME/.local/bin/shellspec`].
2. Delete the ShellSpec installation directory [default: `$HOME/.local/lib/shellspec`].

### Other usage <!-- omit in toc -->

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

<details>
<summary>Package manager (Arch Linux / Homebrew / Linuxbrew / basher / bpkg)</summary>

### Arch Linux <!-- omit in toc -->

Installation on Arch Linux from the AUR [ShellSpec package](https://aur.archlinux.org/packages/shellspec/) using `aura`:

```console
# Install the latest stable version
$ aura -A shellspec
```

### Homebrew / Linuxbrew <!-- omit in toc -->

```console
# Install the latest stable version
$ brew tap shellspec/shellspec
$ brew install shellspec
```

### basher <!-- omit in toc -->

Installation with [basher](https://github.com/basherpm/basher)

**The officially supported version is ShellSpec 0.19.1 and later.**

```console
# Install from master branch
$ basher install shellspec/shellspec

# To specify a version (example: 0.19.1)
$ basher install shellspec/shellspec@0.19.1
```

### bpkg <!-- omit in toc -->

Installation with [bpkg](https://github.com/bpkg/bpkg)

**The officially supported version is ShellSpec 0.19.1 and later.**

```console
# Install from master branch
$ bpkg install shellspec/shellspec

# To specify a version (example: 0.19.1)
$ bpkg install shellspec/shellspec@0.19.1
```

</details>

<details>
<summary>Other methods (archive / make / manual)</summary>

### Archive <!-- omit in toc -->

See [Releases](https://github.com/shellspec/shellspec/releases) page if you want to download distribution archive.

### Make <!-- omit in toc -->

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

### Manual installation <!-- omit in toc -->

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

## Tutorial

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

## ShellSpec CLI

See more info: [ShellSpec CLI](docs/cli.md)

NOTE: ShellSpec CLI ignores shebang except in some cases and runs specfiles with the shell running `shellspec` (normally `/bin/sh`).
For example, if you want to run specfiles in bash, specify the `-s` (`--shell`) option or add the option to `.shellspec` file.

```console
$ shellspec -h
Usage: shellspec [options...] [files or directories...]

  Using + instead of - for short options causes reverses the meaning

    -s, --shell SHELL               Specify a path of shell [default: "auto" (the shell running shellspec)]
        --path PATH                 Set PATH environment variable at startup
        --[no-]sandbox              Force the use of the mock instead of the actual command
        --sandbox-path SANDBOX-PATH Make PATH the sandbox path instead of empty (default: empty)
        --require MODULE            Require a MODULE (shell script file)
    -e, --env NAME=VALUE            Set environment variable
        --env-from ENV-SCRIPT       Set environment variable from shell script file
    -w, --[no-]warning-as-failure   Treat warning as failure [default: enabled]
        --[no-]fail-fast[=COUNT]    Abort the run after first (or COUNT) of failures [default: disabled]
        --[no-]fail-no-examples     Fail if no examples found [default: disabled]
        --[no-]fail-low-coverage    Fail on low coverage [default: disabled]
    -p, --[no-]profile              Enable profiling and list the slowest examples [default: disabled]
        --profile-limit N           List the top N slowest examples [default: 10]
        --[no-]boost                Increase the CPU frequency to boost up testing speed [default: disabled]
        --log-file LOGFILE          Log file for %logger directive and trace [default: /dev/tty]
        --keep-tempdir              Do not cleanup temporary directory [default: disabled]

  **** Execution ****

    -q, --[no-]quick                Run not-passed examples if it exists, otherwise run all [default: disabled]
    -r, --repair, --only-failures   Run failure examples only (Depends on quick mode)
    -n, --next,   --next-failure    Run failure examples and abort on first failure (Depends on quick mode)
    -j, --jobs JOBS                 Number of parallel jobs to run [default: 0 (disabled)]
        --random TYPE[:SEED]        Run examples by the specified random type | <[none]> [specfiles] [examples]
    -x, --xtrace                    Run examples with trace output of evaluation enabled [default: disabled]
    -X, --xtrace-only               Run examples with trace output only enabled [default: disabled]
        --dry-run                   Print the formatter output without running any examples [default: disabled]

  **** Output ****

        --[no-]banner               Show banner if exist 'spec/banner' [default: enabled]
    -f, --format FORMATTER          Choose a formatter for display | <[p]> [d] [t] [j] [f] [null] [debug]
    -o, --output GENERATOR          Choose a generator(s) to generate a report file(s) [default: none]
        --[no-]color                Enable or disable color [default: enabled if the output is a TTY]
        --skip-message VERBOSITY    Mute skip message | <[verbose]> [moderate] [quiet]
        --pending-message VERBOSITY Mute pending message | <[verbose]> [quiet]
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
    -D, --default-path PATH         Set the default path where looks for examples [default: "spec"]

  **** Coverage ****

        --[no-]kcov                 Enable coverage using kcov [default: disabled]
        --kcov-path PATH            Specify kcov path [default: kcov]
        --kcov-options OPTIONS      Additional Kcov options (coverage limits, coveralls id, etc)

  **** Utility ****

        --init [TEMPLATE...]        Initialize your project with ShellSpec | [git] [hg] [svn]
        --gen-bin [@COMMAND...]     Generate test support commands in spec/support/bin
        --count                     Count the number of specfiles and examples
        --list LIST                 List the specfiles/examples | [specfiles] [examples(:id|:lineno)]
        --syntax, --syntax-check    Syntax check of the specfiles without running any examples
        --translate                 Output translated specfile
        --docker DOCKER-IMAGE       Run tests in specified docker image (EXPERIMENTAL)
        --task [TASK]               Run the TASK or Show the task list if TASK is not specified
    -v, --version                   Display the version
    -h, --help                      -h: short help, --help: long help
```

## Project directory structure

See more info: [Directory structure](docs/directory_structure.md)

Typical project directory structure

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

## Specfile (test file)

In ShellSpec, you write your tests in a specfile.
By default, specfile is a file ending with `_spec.sh` under the `spec` directory.

ShellSpec has its own DSL to write tests. You may seem like distinctive code
because DSL starts with a capital letter (to distinguish it from a command),
but the syntax is compatible with shell scripts, and you can embed shell functions
and use [ShellCheck](https://github.com/koalaman/shellcheck) to check the syntax.

```sh
Describe 'lib.sh' # example group
  Describe 'bc command'
    add() { echo "$1 + $2" | bc; }

    It 'performs addition' # example
      When call add 2 3 # evaluation
      The output should eq 5  # expectation
    End
  End
End
```

NOTE: The specfile is not run directly in the shell, but is converted into
regular shell scripts before it is run. If you are interested in
the translated code, you can see with `shellspec --translate`.

### Embedded shell scripts

You can embed shell function (or shell script code) in the specfile.
This shell function can be used for test preparation and complex testing.

Note that the specfile implements the scope using subshell.
Shell functions defined in the specfile can only be used within blocks (e.g. `Describe`, `It`, etc).

If you want to use a global function, you can define it in `spec_helper.sh`.

### Sample

**The best place to learn how to write a specfile is the
[sample/spec](sample/spec) directory. You should take a look at it !**
*(Those samples include failure examples on purpose.)*

## DSL syntax

### Basic structure

#### `Describe`, `Context`, `ExampleGroup` - example group block

`ExampleGroup` is a block for grouping example groups or examples.
`Describe` and `Context` are alias for `ExampleGroup`.
It can be nested and they can contain example groups or examples.

```sh
Describe 'is example group'
  Describe 'is nestable'
    ...
  End

  Context 'is used to make easier to understand depending on the context'
    ...
  End
End
```

#### `It`, `Specify`, `Example` - example block

`Example` is a block for writing evaluation and expectations.
`It` and `Specify` are alias for `Example`.

An example is composed by up to one evaluation and multiple expectations.

```sh
add() { echo "$1 + $2" | bc; }

It 'performs addition'          # example
  When call add 2 3             # evaluation
  The output should eq 5        # expectation
  The status should be success  # another expectation
End
```

#### `Todo` - one liner empty example

`Todo` is the same as the empty example and is treated as [pending](#pending---pending-example) example.

```sh
Todo 'will be used later when write a test'

It 'is empty example, the same as Todo'
End
```

#### `When` - evaluation

Evaluation executes shell function or command for verification.
Only one evaluation can be defined for each example and also can be omitted.

See more details of [Evaluation](docs/references.md#evaluation)

NOTE: [About executing aliases](#about-executing-aliases)

##### `call` - call a shell function (without subshell)

It call a function without subshell.
Practically, it can also run commands.

```sh
When call add 1 2 # call `add` shell function with two arguments.
```

##### `run` - run a command (within subshell)

It runs a command within subshell. Practically, it can also call shell function.
The command does not have to be a shell script.

NOTE: This is not supporting coverage measurement.

```sh
When run touch /tmp/foo # run `touch` command.
```

Some commands below are specially handled by ShellSpec.

###### `command` - runs a external command

It runs a command, respecting shebang.
It can not call shell function. The command does not have to be a shell script.

NOTE: This is not supporting coverage measurement.

```sh
When run command touch /tmp/foo # run `touch` command.
```

###### `script` - runs a shell script

It runs a shell script, ignoring shebang. The script have to be a shell script.
It will be executed in another instance of the same shell as the current shell.

```sh
When run script my.sh # run `my.sh` script.
```

###### `source` - runs a script by `.` (dot) command

It source a shell script, ignoring shebang. The script have to be a shell script.
It similar to `run script`, but with some differences.
Unlike `run script`, function-based mock is available.

```sh
When run source my.sh # source `my.sh` script.
```

##### About executing aliases

If you want to execute aliases, you need a workaround using `eval`.

```sh
alias alias-name='echo this is alias'
When call alias-name # alias-name: not found

# eval is required
When call eval alias-name

# When using embedded shell scripts
foo() { eval alias-name; }
When call foo
```

#### `The` - expectation

Expectation begin with `The`, which does the verification.
The basic syntax is as follows:

```sh
The output should equal 4
```

Use `should not` for the opposite verification.

```sh
The output should not equal 4
```

##### Subjects

The subject is the target of verification.

```sh
The output should equal 4
      |
      +-- subject
```

There are `output` (`stdout`), `error` (`stdout`), `status`, `variable`, `path`, etc.

Please refer to the [Subjects](docs/references.md#subjects) for more details.

##### Modifiers

The modifier is modified the verification target.

```sh
The line 2 of output should equal 4
      |
      +-- modifier
```

The modifier is chainable.

```sh
The word 1 of line 2 of output should equal 4
```

If the modifier argument is a number, you can use ordinal numbers instead of a number.

```sh
The first word of second line of output should equal 4
```

There are `line`, `word`, `length`, `contents`, `result`, etc.
The `result` modifier is useful for making the result of a user-defined function the subject.

Please refer to the [Modifiers](docs/references.md#modifiers) for more details.

##### Matchers

The matcher is the verification.

```sh
The output should equal 4
                   |
                   +-- matcher
```

There are many matchers such as string matcher, status matcher, variable matchers and stat matchers.
The `satisfy` matcher is useful for verification with user-defined function.

Please refer to the [Matchers](docs/references.md#matchers) for more details.

##### Language chains

ShellSpec supports *language chains* like [chai.js](https://www.chaijs.com/).
It only improves readability, does not affect the expectation: `a`, `an`, `as`, `the`.

The following two sentences have the same meaning:

```sh
The first word of second line of output should valid number

The first word of the second line of output should valid as a number
```

#### `Assert` - expectation for custom assertion

The `Assert` is yet another expectation to verify with a user-defined function.
It is designed for verification of side effects, not result of evaluation.

```sh
still_alive() {
  ping -c1 "$1" >/dev/null
}

Describe "example.com"
  It "responses"
    Assert still_alive "example.com"
  End
End
```

### Pending, skip and focus

#### `Pending` - pending example

`Pending` is similar to `Skip`, but the test passes if the validation fails,
and the test fails if the validation succeeds. This is useful if you want to
specify that you will implement it later.

```sh
Describe 'Pending'
  Pending "not implemented"

  hello() { :; }

  It 'will success when test fails'
    When call hello world
    The output should "Hello world"
  End
End
```

#### `Skip` - skip example

Use `Skip` to skip executing the example.

```sh
Describe 'Skip'
  Skip "not exists bc"

  It 'is always skip'
    ...
  End
End
```

##### `if` - conditional skip

Use `Skip if` if you want to skip with conditional.

```sh
Describe 'Conditional skip'
  not_exists_bc() { ! type bc >/dev/null 2>&1; }
  Skip if "not exists bc" not_exists_bc

  add() { echo "$1 + $2" | bc; }

  It 'performs addition'
    When call add 2 3
    The output should eq 5
  End
End
```

#### 'x' prefix for example group and example

##### `xDescribe`, `xContext`, `xExampleGroup` - skipped example group

`xDescribe`, `xContext`, `xExampleGroup` are skipped example group block.
Execution of example contained in these is skipped.

```sh
Describe 'is example group'
  xDescribe 'is skipped example group'
    ...
  End
End
```

##### `xIt`, `xSpecify`, `xExample` - skipped example

`xIt`, `xSpecify`, `xExample` are skipped example block.
Execution of example is skipped.

```sh
xIt 'is skipped example'
  ...
End
```

#### 'f' prefix for example group and example

##### `fDescribe`, `fContext`, `fExampleGroup` - focused example group

`fDescribe`, `fContext`, `fExampleGroup` are focused example group block.
Only the examples included in these will be executed when the `--focus` option is specified.

```sh
Describe 'is example group'
  fDescribe 'is focues example group'
    ...
  End
End
```

##### `fIt`, `fSpecify`, `fExample` - focused example

`fIt`, `fSpecify`, `fExample` are focused example block.
Only these examples will be executed when the `--focus` option is specified.

```sh
fIt 'is focused example'
  ...
End
```

#### About temporary pending and skip

The pending and skip without message is "temporary pending" and "temporary skip.
"x" prefixed example groups and examples are treated as temporary skip.

The (non-temporary) pending and skip is used when it takes a long time to resolve.
It may also commit to a version control system. The temporary pending and skip is used during the current work.
We do not recommend committing it to a version control system.

These two types are differ in the display of the report. Refer to `--skip-message` and `--pending-message` options.

```sh
# Temporary pending and skip
Pending
Skip
Skip # this comment will be displayed in the report
Todo
xIt
  ...
End

# Non-temporary pending and skip
Pending "reason"
Skip "reason"
Skip if "reason" condition
Todo "It will be implemented"
```

### Hooks

#### `BeforeEach` (`Before`), `AfterEach` (`After`) - example hook

You can specify commands to be executed before / after each example by `BeforeEach` (`Before`), `AfterEach` (`After`).

NOTE: `BeforeEach` and `AfterEach` are supported in version 0.28.0 and later.
Previous versions should use `Before` and `After` instead.

NOTE: `AfterEach` is for cleanup and do not use for assertions.

```sh
Describe 'example hook'
  setup() { :; }
  cleanup() { :; }
  BeforeEach 'setup'
  AfterEach 'cleanup'

  It 'is called before and after each example'
    ...
  End

  It 'is called before and after each example'
    ...
  End
End
```

#### `BeforeAll`, `AfterAll` - example group hook

You can specify commands to be executed before / after all examples by `BeforeAll` and `AfterAll`

```sh
Describe 'example all hook'
  setup() { :; }
  cleanup() { :; }
  BeforeAll 'setup'
  AfterAll 'cleanup'

  It 'is called before/after all example'
    ...
  End

  It 'is called before/after all example'
    ...
  End
End
```

#### `BeforeCall`, `AfterCall` - call evaluation hook

You can specify commands to be executed before / after call evaluation by `BeforeCall` and `AfterCall`

NOTE: These hooks were originally created to test ShellSpec itself.
Please use the `BeforeEach` / `AfterEach` hooks whenever possible.

```sh
Describe 'call evaluation hook'
  setup() { :; }
  cleanup() { :; }
  BeforeCall 'setup'
  AfterCall 'cleanup'

  It 'is called before/after call evaluation'
    When call hello world
    ...
  End
End
```

#### `BeforeRun`, `AfterRun` - run evaluation hook

You can specify commands to be executed before / after run evaluation
(`run`, `run command`, `run script` and `run source`) by `BeforeRun` and `AfterRun`

These hooks are executed in the same subshell as the "run evaluation".
Therefore, you can access the variables after executing the evaluation.

NOTE: These hooks were originally created to test ShellSpec itself.
Please use the `BeforeEach` / `AfterEach` hooks whenever possible.

```sh
Describe 'run evaluation hook'
  setup() { :; }
  cleanup() { :; }
  BeforeRun 'setup'
  AfterRun 'cleanup'

  It 'is called before/after run evaluation'
    When run hello world
    ...
  End
End
```

### Helpers

#### `Dump` - dump stdout, stderr and status for debugging

Dump stdout, stderr and status of the evaluation. It is useful for debugging.

```sh
When call echo hello world
Dump # stdout, stderr and status
```

#### `Include` - include a script file

Include the shell script to test.

```sh
Describe 'lib.sh'
  Include lib.sh # hello function defined

  Describe 'hello()'
    It 'says hello'
      When call hello ShellSpec
      The output should equal 'Hello ShellSpec!'
    End
  End
End
```

#### `Set` - set shell option

Set shell option before executing each example.
The shell option name is the long name of `set` or the name of `shopt`:

NOTE: Use `Set` instead of the `set` command because the `set` command
may not work as expected in some shells.

```sh
Describe 'Set helper'
  Set 'errexit:off' 'noglob:on'

  It 'sets shell options before executiong the example'
    When call foo
  End
End
```

#### `Path`, `File`, `Dir` - path alias

`Path` is used to define a short pathname alias.
`File` and `Dir` are alias for `Path`.

```sh
Describe 'Path helper'
  Path hosts-file="/etc/hosts"

  It 'defines short alias for long path'
    The path hosts-file should be exists
  End
End
```

#### `Data` - pass data as stdin to evaluation

You can use the Data Helper which inputs data from stdin for evaluation.
The input data is specified after `#|` in the `Data` or `Data:expand` block.

```sh
Describe 'Data helper'
  It 'provides with Data helper block style'
    Data # Use Data:expand instead if you want expand variables.
      #|item1 123
      #|item2 456
      #|item3 789
    End
    When call awk '{total+=$2} END{print total}'
    The output should eq 1368
  End
End
```

You can also use a file, function, or string as data sources.

See more details of [Data](docs/references.md##data)

#### `Parameters` - parameterized example

Parameterized test (aka Data Driven Test) is used to run the same test with
different parameters. `Parameters` defines its parameters.

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

In addition to the default `Parameters`, three styles are supported:
`Parameters:value`, `Parameters:matrix` and `Parameters:dynamic`.

See more details of [Parameters](docs/references.md##parameters)

NOTE: You can also cooperate the `Parameters` and `Data:expand` helpers.

#### `Mock` - create a command-based mock

See [Command-based mock](#command-based-mock)

#### `Intercept` - create an intercept point

See [Intercept](#intercept)

## Directives

Directives are instructions that can be used in embedded shell scripts.
It is used to solve small problems of shell scripts in testing.

This is like a shell function, but not a shell function.
Therefore, the supported grammar is limited and can only be used at the
beginning of a function definition or at the beginning of a line.

```sh
foo() { %puts "foo"; } # supported

bar() {
  %puts "bar" # supported
}

baz() {
  any command; %puts "baz" # not supported
}
```

### `%const` (`%`) - constant definition

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

### `%text` - embedded text

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

    result() { %text
      #|start
      #|aaa
      #|bbb
      #|ccc
      #|end
    }

    When call output
    The output should eq "$(result)"
    The line 3 of output should eq 'bbb'
  End
End
```

### `%puts` (`%-`), `%putsn` (`%=`) - output a string (with newline)

`%puts` (put string) and `%putsn` (put string with newline) can be used instead
of (not portable) echo. Unlike echo, it does not interpret escape sequences
regardless of the shell. `%-` is an alias of `%puts`, `%=` is an alias of
`%putsn`.

### `%printf` - alias for printf

This is same as `printf`, But it can be used in sandbox mode because the path has been resolved.

### `%sleep` - alias for sleep

This is same as `sleep`, But it can be used in sandbox mode because the path has been resolved.

### `%preserve` - preserve variables

Use `%preserve` directive to preserve the variables in subshells and external shell script.

In the following cases, `%preserve` is required because variables are not preserved.

- `When run` evaluation - It runs in a subshell.
- Command-based mock (`Mock`) - It is an external shell script.
- Function-based Mock called by command substitution

```sh
Describe '%preserve directive'
  It 'preserves variables'
    func() { foo=1; bar=2; baz=3; }
    preserve() { %preserve bar baz:BAZ; }
    AfterRun preserve

    When run func
    The variable foo should eq 1 # This will be failure
    The variable bar should eq 2 # This will be success
    The variable BAZ should eq 3 # Preserved to different variable (baz:BAZ)
  End
End
```

### `%logger` - debug output

Output log messages to the log file (default: `/dev/tty`) for debugging.

### `%data` - define parameter

See `Parameters`.

## Mocking

There are two ways to create a mock, function-based mock and command-based mock.
The function-based mock is usually recommended for performance reasons.
Both can be overwritten with an internal block and will be restored when the block ends.

### Function-based mock

The function-based mock is simply (re)defined with shell function.

```sh
Describe 'function-based mock'
  get_next_day() { echo $(($(date +%s) + 86400)); }

  date() {
    echo 1546268400
  }

  It 'calls the date function'
    When call get_next_day
    The stdout should eq 1546354800
  End
End
```

### Command-based mock

The command-based mock is create a temporary mock shell script and run as external command.
To accomplish this, a directory for mock commands is included at the beginning of `PATH`.

This is slow, but there are some advantages over function-based.

- You can use invalid characters as the shell function name.
  - e.g `docker-compose` (It can be defined with bash etc., but invalid as POSIX.)
- You can use the mock command from an external shell script.

A command-based mock creates an external shell script with the contents of
a `Mock` block. Therefore, there are some restrictions.

- You cannot call shell functions outside the `Mock` block.
  - Only bash can export and call shell functions with `export -f`.
- To reference a variable outside the `Mock` block, that variable must be exported.
- `%preserve` directive is required to return a variable from a `Mock` block.

```sh
Describe 'command-based mock'
  get_next_day() { echo $(($(date +%s) + 86400)); }

  Mock date
    echo 1546268400
  End

  It 'runs the mocked date command'
    When call get_next_day
    The stdout should eq 1546354800
  End
End
```

## Support commands

### Execute the actual command within a mock function

Support commands are helper commands that can be used in the specfile.
For example, it can be used in a mock function to execute the actual command.
It is recommended that the support command name be the actual command name prefixed with `@`.

```sh
Describe "Support commands sample"
  touch() {
    @touch "$@" # @touch executes actual touch command
    echo "$1 was touched"
  }

  It "touch a file"
    When run touch "file"
    The output should eq "file was touched"
    The file "file" should be exist
  End
End
```

Support commands are generate to the `spec/support/bin` directory by `--gen-bin` option.
For example, run `shellspec --gen-bin @touch` to generate the `@touch` command.

This is main purpose but support commands is just shell script, so you can
also be used for other purposes. You can freely edit the support command script.

### Make mock not mandatory in sandbox mode

The sandbox mode is force the use of the mock. However, you may not want to require mocks in some commands.
For example, `printf` is a built-in command in many shells and does not require a mock,
but some shells require a mock in sandbox mode because it is an external command.

To allow `printf` to be called without mocking in such cases,
create a support command named `printf` (`shellspec --gen-bin printf`).

### Resolve command incompatibilities

Some commands have different options between BSD and GNU.
If you handle the difference in the specfile, the test will be hard to read.
You can solve it with the support command.

```sh
#!/bin/sh -e
# Command name: @sed
. "$SHELLSPEC_SUPPORT_BIN"
case $OSTYPE in
  *darwin*) invoke gsed "$@" ;;
  *) invoke sed "$@" ;;
esac
```

## Testing a single file script

Shell scripts are often made up of a single file. ShellSpec provides two ways
of testing a single shell script.

### Sourced Return

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

### Intercept

This is a method to mock functions and commands when executing shell
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

## Self-executable specfile

Normally, you use `shellspec` to run a specfile.
If you want to run a specfile directly, use shebang below and give execute permission.

```sh
#!/usr/bin/env shellspec
```

If you want to use `#!/bin/sh` as shebang, by adding `eval "$(shellspec -)"` to
the top of the specfile.

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

## Use with Docker

You can run ShellSpec without installation by using Docker. ShellSpec and
specfiles run in a Docker container.

See [How to use ShellSpec with Docker](docs/docker.md).

## Extension

### Custom subject, modifier and matcher

You can create custom subject, custom modifier and custom matcher.

See [sample/spec/support/custom_matcher.sh](sample/spec/support/custom_matcher.sh) for custom matcher.

NOTE: If you want to verify using shell function, You can use [result](docs/references.md#result) modifier or
[satisfy](docs/references.md#satisfy) matcher. You don't necessarily have to create a custom matcher, etc.

## For developers

### Subprojects

#### ShellMetrics - Cyclomatic Complexity Analyzer for shell scripts

URL: [https://github.com/shellspec/shellmetrics](https://github.com/shellspec/shellmetrics)

#### ShellBench - A benchmark utility for POSIX shell comparison

URL: [https://github.com/shellspec/shellbench](https://github.com/shellspec/shellbench)

### Related projects

#### getoptions - An elegant option parser and generator for shell scripts

URL: [https://github.com/ko1nksm/getoptions](https://github.com/ko1nksm/getoptions)

#### readlinkf - readlink -f implementation for shell scripts

URL: [https://github.com/ko1nksm/readlinkf](https://github.com/ko1nksm/readlinkf)

### Inspired frameworks

- [RSpec](https://rspec.info/) - Behaviour Driven Development for Ruby
- [Jest](https://jestjs.io/]) - Delightful JavaScript Testing
- [Mocha](https://mochajs.org/) - the fun, simple, flexible JavaScript test framework
- [Jasmine](https://jasmine.github.io/) - Behavior-Driven JavaScript
- [Ginkgo](https://onsi.github.io/ginkgo/) - A Golang BDD Testing Framework
- [JUnit 5](https://junit.org/junit5/) - The programmer-friendly testing framework for Java

### Contributions

All contributions are welcome!

ShellSpec use an peculiar coding style as for shell scripts to realize high performance,
reliability and portability, and the external commands that allowed to use are also greatly restricted.

We recommend that you create WIP PR early or offer suggestions in discussions to avoid ruining your work.

See [CONTRIBUTING.md](CONTRIBUTING.md)
