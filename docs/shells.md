# Shells

- [Tested shells and versions](#tested-shells-and-versions)
  - [Packages](#packages)
    - [Alpine / BusyBox / OpenWrt (LEDE)](#alpine--busybox--openwrt-lede)
    - [CentOS / Fedora](#centos--fedora)
    - [Debian / Ubuntu](#debian--ubuntu)
    - [FreeBSD](#freebsd)
    - [macOS](#macos)
    - [Windows](#windows)
  - [Self build](#self-build)
    - [Schily Bourne Shell](#schily-bourne-shell)
    - [GWSH shell](#gwsh-shell)
  - [Manual test](#manual-test)
    - [Solaris](#solaris)
    - [OpenBSD / NetBSD](#openbsd--netbsd)
    - [AIX](#aix)
- [Confirmation for bug](#confirmation-for-bug)
- [Built-in commands](#built-in-commands)

## Tested shells and versions

- **The version with a dash does not work.**
- **The version in italic may work but it is not supported due to a bug.**
- The shell included with the supported OS (the platform in bold) is the main supported shell.
- The old shell has been tested, but support may be discontinued.
- Supported busybox shell is `ash` only. `hush` has many missing features and bugs.
- pdksh 5.2.14 is still supported, but it has many bugs, too old and no more maintained. Not recommended for use.
- Bourne shell is not supported.

### Packages

- These are tested by [Travis CI][travis], [Cirrus CI][cirrus] and Docker (`contrib/test_in_docker.sh`).

[travis]: https://travis-ci.org/shellspec/shellspec
[cirrus]: https://cirrus-ci.com/github/shellspec/shellspec

#### Alpine / BusyBox / OpenWrt (LEDE)

Default shell: `busybox ash`

| Platform            | bash   | busybox  | dash | loksh | mksh | yash | zsh |
| ------------------- | ------ | -------- | ---- | ----- | ---- | ---- | --- |
| **Alpine 3.12.0**   | 5.0.17 | 1.31.1   |      | 6.7   |      | -    |     |
| **BusyBox 1.32.1**  | -      | 1.32.0   | -    | -     | -    | -    | -   |
| LEDE 17.01.7        |        | 1.25.1   | -    | -     |      | -    |     |
| OpenWrt 10.03.1     |        | _1.15.3_ |      | -     |      | -    | -   |
| OpenWrt 12.09       |        | _1.19.4_ |      | -     |      | -    | -   |
| OpenWrt 14.07       |        | 1.22.1   |      | -     |      | -    |     |
| OpenWrt 15.05.1     |        | 1.23.2   | -    | -     |      | -    |     |
| **OpenWrt 18.06.8** |        | 1.28.4   | -    | -     |      | -    |     |
| **OpenWrt 19.07.3** |        | 1.30.1   | -    | -     |      | -    |     |

#### CentOS / Fedora

Default shell: `bash`

| Platform            | bash   | busybox | dash | ksh | mksh | yash | zsh   |
| ------------------- | ------ | ------- | ---- | --- | ---- | ---- | ----- |
| **CentOS 6.10**     | 4.1.2  |         |      |     |      | -    |       |
| **CentOS 7.7.1908** | 4.2.46 | -       | -    |     |      | -    |       |
| **CentOS 8.1.1911** | 4.4.19 | -       | -    |     |      | -    | 5.5.1 |
| fedora 20           | 4.2.53 |         |      |     |      |      |       |
| fedora 21           | 4.3.30 |         |      |     |      |      |       |
| fedora 24           | 4.3.42 |         |      |     |      |      |       |
| fedora 25           | 4.3.43 |         |      |     |      |      |       |
| fedora 26           | 4.4.12 |         |      |     |      |      |       |
| fedora 29           | 4.4.23 |         |      |     |      |      |       |
| **fedora 31**       | 5.0.7  |         |      |     |      |      |       |
| **fedora 32**       | 5.0.11 |         |      |     |      |      |       |

- Testing bash 4.1.2- in POSIX mode only.

#### Debian / Ubuntu

Default shell: `dash` or `bash` (until debian 5.0)

| Platform         | bash   | busybox    | dash          | ksh             | mksh | pdksh      | posh     | yash | zsh    |
| ---------------- | ------ | ---------- | ------------- | --------------- | ---- | ---------- | -------- | ---- | ------ |
| Debian 2.2r7     | 2.03   | -          | -             | -               | -    | ~~5.2.14~~ | -        | -    | 3.1.9  |
| Debian 3.0r6     | 2.05a  | ~~0.60.2~~ | ~~ash 0.3.8~~ | -               | -    | 5.2.14     | -        | -    | 4.0.4  |
| Debian 3.1r8     | 2.05b  | ~~0.60.5~~ | 0.5.2         | ~~93q~~         | -    | 5.2.14     | 0.3.14   | -    | 4.2.5  |
| Debian 4.0r9     | 3.1.17 | _1.1.3_    | 0.5.3         | _93r_           | R28  | 5.2.14     | 0.5.4    | -    | 4.3.2  |
| Debian 5.0.10    | 3.2.39 | 1.10.2     | 0.5.4         | 93s+ 2008-01-31 | R35  | 5.2.14     | 0.6.13   | -    | 4.3.6  |
| Debian 6.0.10    | 4.1.5  | 1.17.1     | 0.5.5.1       | 93s+ 2008-01-31 | R39  | 5.2.14     | 0.8.5    | -    | 4.3.10 |
| Debian 7.11      | 4.2.37 | 1.20.0     | 0.5.7         | 93u+ 2012-02-29 | R40  | -          | _0.10.2_ | 2.30 | 4.3.17 |
| **Debian 8.11**  | 4.3.30 | 1.22.0     | 0.5.7         | 93u+ 2012-08-01 | R50d | -          | 0.12.3   | 2.36 | 5.0.7  |
| **Debian 9.12**  | 4.4.12 | 1.22.0     | 0.5.8         | 93u+ 2012-08-01 | R54  | -          | 0.12.6   | 2.43 | 5.3.1  |
| **Debian 10.3**  | 5.0.3  | 1.30.1     | 0.5.10.2      | 93u+ 2012-08-01 | R57  | -          | 0.13.2   | 2.48 | 5.7.1  |
| Debian bullseye  |        |            |               | 2020.0.0        | R59b | -          | 0.14.1   | 2.50 | 5.8    |
| Ubuntu 12.04     | 4.2.25 | 1.18.5     | 0.5.7         | 93u 2011-02-08  | R40  | -          | _0.10_   | 2.29 | 4.3.17 |
| **Ubuntu 14.04** | 4.3.11 | 1.21.0     | 0.5.7         | 93u+ 2012-08-01 | R46  | -          | 0.12.3   | 2.35 | 5.0.2  |
| **Ubuntu 16.04** | 4.3.48 | 1.22.0     | 0.5.8         | 93u+ 2012-08-01 | R52c | -          | 0.12.6   | 2.39 | 5.1.1  |
| **Ubuntu 18.04** | 4.4.20 | 1.27.2     | 0.5.8         | 93u+ 2012-08-01 | R56c | -          | 0.13.1   | 2.46 | 5.4.2  |
| **Ubuntu 20.04** | 5.0.16 | 1.30.1     | 0.5.10.2      | 2020.0.0        | R58  | -          | 0.13.1   | 2.49 | 5.8    |

- Use [debian/eol](https://hub.docker.com/r/debian/eol) docker images for older Debian versions.
- Testing bash 2.03-3.2.39 in both POSIX and non-POSIX mode. bash 4.1.5- is non-POSIX mode only.

#### FreeBSD

Default shell: `ash`

| Platform         | ash     | bash   | dash     | ksh             | mksh | oksh     | pdksh    | zsh   |
| ---------------- | ------- | ------ | -------- | --------------- | ---- | -------- | -------- | ----- |
| FreeBSD 10.4     | unknown | 4.4.23 | 0.5.10.2 | 93u+ 2012-08-01 | R56c | 20181009 | _5.2.14_ | 5.6.2 |
| **FreeBSD 11.4** | unknown | 5.0.16 | 0.5.10.2 | 93u+ 2012-08-01 | R57  | 6.6      | _5.2.14_ | 5.8   |
| **FreeBSD 12.1** | unknown | 5.0.16 | 0.5.10.2 | 93u+ 2012-08-01 | R57  | 6.6      | _5.2.14_ | 5.8   |

- pdksh is unstable on CI environment (Bus Error, Bad address, Memory fault, core dumped and etc).

#### macOS

Default shell: `bash`

| Platform               | sh          | bash   | dash     | ksh             | mksh | posh       | yash | zsh   |
| ---------------------- | ----------- | ------ | -------- | --------------- | ---- | ---------- | ---- | ----- |
| macOS 10.10            | bash 3.2.57 | 3.2.57 | -        | 93u+ 2012-08-01 | -    | -          | -    | 5.0.5 |
| macOS 10.11            | bash 3.2.57 | 3.2.57 | -        | 93u+ 2012-08-01 | -    | -          | -    | 5.0.8 |
| macOS 10.12            | bash 3.2.57 | 3.2.57 | -        | 93u+ 2012-08-01 | -    | -          | -    | 5.2   |
| **macOS 10.13**        | bash 3.2.57 | 3.2.57 | -        | 93u+ 2012-08-01 | -    | -          | -    | 5.3   |
| **macOS 10.14**        | bash 3.2.57 | 3.2.57 | -        | 93u+ 2012-08-01 | -    | -          | -    | 5.3   |
| **macOS 10.15**        | bash 3.2.57 | 3.2.57 | -        | 93u+ 2012-08-01 | -    | -          | -    | 5.7.1 |
| **macOS 10.15 (brew)** | -           | 5.0.17 | 0.5.10.2 | 2020.0.0        | R59  | ~~0.13.2~~ | 2.50 | 5.8   |

- Supports the latest three versions.
- posh on macOS (homebrew) is broken?

#### Windows

Default shell: `bash`

| Platform                              | bash   | busybox       | dash    | mksh | posh   | zsh   |
| ------------------------------------- | ------ | ------------- | ------- | ---- | ------ | ----- |
| **Windows Server 2019 (Git Bash)**    | 4.4.23 | -             | unknown | -    | -      | -     |
| **Windows Server 2019 (msys)**        | 4.4.23 | 1.31.1        | 0.5.11  | R57  | -      | 5.8   |
| **Windows Server 2019 (cygwin)**      | 4.4.12 | 1.23.2        | 0.5.9.1 | R56c | 0.13.2 | 5.5.1 |
| **Windows Server 2019 (busybox-w32)** | -      | 1.32.0 (3466) | -       | -    | -      | -     |

- busybox-w32: https://frippery.org/busybox/

### Self build

These are tested by Docker (`contrib/test_in_docker.sh`).

#### Schily Bourne Shell

| Platform                             | bosh / pbosh |
| ------------------------------------ | ------------ |
| Debian buster + Schily AN-2018-10-30 | 2018/10/07   |
| Debian buster + Schily AN-2019-03-11 | 2019/02/05   |
| Debian buster + Schily AN-2019-09-22 | 2019/08/25   |
| Debian buster + Schily AN-2019-10-07 | 2019/09/27   |
| Debian buster + Schily AN-2019-12-05 | 2019/10/25   |
| Debian buster + Schily AN-2020-02-11 | 2020/01/24   |
| Debian buster + Schily AN-2020-03-27 | 2020/03/25   |
| Debian buster + Schily AN-2020-04-18 | _2020/04/10_ |
| Debian buster + Schily AN-2020-05-11 | 2020/04/27   |

- [Schily Bourne Shell][bosh] (`bosh`, `pbosh`)
- Packages are available on [The NetBSD package collection][pkgsrc].
- Versions before 2018/10/07 does not work.

[bosh]: http://schilytools.sourceforge.net/bosh.html
[pkgsrc]: http://pkgsrc.se/shells/bosh

#### GWSH shell

| Platform      | gwsh              |
| ------------- | ----------------- |
| Debian buster | snapshot-20190627 |

- [GWSH shell](https://github.com/hvdijk/gwsh/releases)

### Manual test

This is not continuous test, it may break sometimes...

- \* Reported by user

#### Solaris

| Platform       | /bin/sh               | /usr/bin/ksh      | /usr/sunos/bin/ksh | /usr/sunos/bin/sh |
| -------------- | --------------------- | ----------------- | ------------------ | ----------------- |
| **Solaris 10** | ~~Bourne Shell~~      | ksh88 M-11/16/88i | -                  | -                 |
| **Solaris 11** | ksh93 93u+ 2012-08-01 | -                 | ksh88 M-11/16/88i  | ~~Bourne Shell~~  |

#### OpenBSD / NetBSD

| Platform           | /bin/sh                                        | /usr/bin/ksh |
| ------------------ | ---------------------------------------------- | ------------ |
| FreeBSD 13 current | FreeBSD sh (ash)                               | -            |
| **OpenBSD 6.6**    | OpenBSD ksh (POSIX mode pdksh) 5.2.14          | pdksh 5.2.14 |
| **NetBSD 9.0**     | NetBSD sh (ash) 20181212 BUILD:20200214000628Z | pdksh 5.2.14 |

#### AIX

| Platform      | Shells      |
| ------------- | ----------- |
| AIX 7.2.1.4 * | bash 4.3.30 |

## Confirmation for bug

`contrib/bugs.sh` detects shell bugs and problems.

Usage: `contrib/bugs.sh`

## Built-in commands

`contrib/builtins.sh` is a script for listing built-in commands.

Usage: `contrib/builtins.sh`
