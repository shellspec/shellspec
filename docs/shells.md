# Shells

## Tested shell and version

### Main test (docker)

* **The version of strikethrough is does NOT work.**
* **The italic version may work but is not supported.**
* The shell that includes with the supported os is the main support.
* The old shell has been tested, but support may be discontinued.

| Platform       | bash  | busybox ash | dash     | ksh   | mksh | pdksh    | posh   | yash | zsh    | bosh / pbosh |
| -------------- | ----- | ----------- | -------- | ----- | ---- | -------- | ------ | ---- | ------ | ------------ |
| alpine latest  |       | 1.29.3      |          |       |      |          |        |      |        |              |
| alpine edge    |       | 1.30.1      |          |       |      |          |        |      |        |              |
| busybox        |       | 1.30.1      |          |       |      |          |        |      |        |              |
| debian 2.2     | 2.03  |             |          |       |      | _5.2.14_ |        |      | 3.1.9  |              |
| debian 3.0     | 2.05a | ~~0.60.2~~  |          |       |      | 5.2.14   |        |      | 4.0.4  |              |
| debian 3.1     | 2.05b | ~~0.60.5~~  | 0.5.2    | _93q_ |      | 5.2.14   | 0.3.14 |      | 4.2.5  |              |
| debian 4.0     | 3.1   | _1.1.3_     | 0.5.3    | _93r_ | 28   | 5.2.14   | 0.5.4  |      | 4.3.2  |              |
| debian 5.0     | 3.2   | 1.10.2      | 0.5.4    | 93s   | 35.2 | 5.2.14   | 0.6.13 |      | 4.3.6  |              |
| debian 6       | 4.1.5 | 1.17.1      | 0.5.5.1  | 93s   | 39   | 5.2.14   | 0.8.5  |      | 4.3.10 |              |
| debian 7       | 4.2   | 1.20.0      | 0.5.7    | 93u   | 40.9 |          | 0.10.2 | 2.30 | 4.3.17 |              |
| debian 8       | 4.3   | 1.22.0      | 0.5.7    | 93u   | 50d  |          | 0.12.3 | 2.36 | 5.0.7  |              |
| debian 9       | 4.4   | 1.22.0      | 0.5.8    | 93u   | 54   |          | 0.12.6 | 2.43 | 5.3.1  |              |
| debian 10      | 5.0.3 | 1.30.1      | 0.5.10.2 | 93u   | 57   |          | 0.13.2 | 2.48 | 5.7.1  |              |
| Ubuntu 16.04   |       |             |          |       | 52c  |          |        |      | 5.1.1  |              |
| Ubuntu 18.04   |       | 1.27.2      |          |       | 56c  |          | 0.13.1 |      | 5.4.2  |              |
| Ubuntu 19.04   |       |             |          |       |      |          |        |      | 5.5.1  |              |
| buildpack-deps |       |             |          |       |      |          |        |      |        | 20181030     |
| buildpack-deps |       |             |          |       |      |          |        |      |        | 20190311     |

I confirmed that works with [Schily Bourne Shell](http://schilytools.sourceforge.net/bosh.html) (`bosh`, `pbosh`) linux build, but not well tested.

### Additional test (manual)

* Solaris 10 : bash 3.2.51, _ksh88_ (/usr/bin/ksh), ~~/bin/sh~~
* Solaris 11 : bash 4.4.19, ksh93 (/bin/sh), _ksh88 (/usr/sunos/bin/ksh)_ , ~~/usr/sunos/bin/sh~~

## Confirmation for bug

`contrib/bugs.sh` detects shell bugs and problems.

Usage: `contrib/bugs.sh`

## Built-in commands

`contrib/builtins.sh` is a script for listing built-in commands.

Usage: `contrib/builtins.sh`

### List

* This is not complete list.
* It may not be implemented in older versions.
* It may implemented in newer versions.
* The options implemented may be different.
* Commands in bold are implemented in all shells.
* zsh has many builtin command begin with "comp" and "z".

|               | dash  | bash | zsh | ksh | mksh | posh | yash | busybox | bosh | pbosh |
| ------------- | ----- | ---- | --- | --- | ---- | ---- | ---- | ------- | ---- | ----- |
| **.**         | o     | o    | o   | o   | o    | o    | o    | o       | o    | o     |
| **:**         | o     | o    | o   | o   | o    | o    | o    | o       | o    | o     |
| **[**         | o     | o    | o   | o   | o    | o    | o    | o       | o    | o     |
| alias         | o     | o    | o   | o   | o    | -    | o    | o       | o    | o     |
| array         | -     | -    | -   | -   | -    | -    | o    | -       | -    | -     |
| autoload      | -     | -    | o   | -   | -    | -    | -    | -       | -    | -     |
| bg            | o     | o    | o   | o   | o    | -    | o    | o       | o    | o     |
| bind          | -     | o    | -   | -   | o    | -    | -    | -       | -    | -     |
| bindkey       | -     | -    | o   | -   | -    | -    | o    | -       | -    | -     |
| **break**     | o     | o    | o   | o   | o    | o    | o    | o       | o    | o     |
| builtin       | -     | o    | o   | o   | o    | o    | -    | -       | o    | -     |
| bye           | -     | -    | o   | -   | -    | -    | -    | -       | -    | -     |
| caller        | -     | o    | -   | -   | -    | -    | -    | -       | -    | -     |
| cap           | -     | -    | o   | -   | -    | -    | -    | -       | -    | -     |
| cat           | -     | -    | -   | -   | o    | -    | -    | -       | -    | -     |
| **cd**        | o     | o    | o   | o   | o    | o    | o    | o       | o    | o     |
| chdir         | o     | -    | o   | -   | o    | -    | -    | o       | o    | o     |
| clone         | -     | -    | o   | -   | -    | -    | -    | -       | -    | -     |
| **command**   | o     | o    | o   | o   | o    | o    | o    | o       | o    | o     |
| compgen       | -     | o    | -   | -   | -    | -    | -    | -       | -    | -     |
| ------------- | dash  | bash | zsh | ksh | mksh | posh | yash | busybox | bosh | pbosh |
| complete      | -     | o    | -   | -   | -    | -    | o    | -       | -    | -     |
| compopt       | -     | o    | -   | -   | -    | -    | -    | -       | -    | -     |
| **continue**  | o     | o    | o   | o   | o    | o    | o    | o       | o    | o     |
| declare       | -     | o    | o   | -   | -    | -    | -    | -       | -    | -     |
| dirs          | -     | o    | o   | -   | -    | -    | o    | -       | o    | -     |
| disable       | -     | -    | o   | -   | -    | -    | -    | -       | -    | -     |
| disown        | -     | o    | o   | o   | -    | -    | o    | -       | -    | -     |
| **echo**      | o     | o    | o   | o   | o    | o    | o    | o       | o    | o     |
| echotc        | -     | -    | o   | -   | -    | -    | -    | -       | -    | -     |
| echoti        | -     | -    | o   | -   | -    | -    | -    | -       | -    | -     |
| emulate       | -     | -    | o   | -   | -    | -    | -    | -       | -    | -     |
| enable        | -     | o    | o   | -   | -    | -    | -    | -       | -    | -     |
| enum          | -     | -    | -   | o   | -    | -    | -    | -       | -    | -     |
| **eval**      | o     | o    | o   | o   | o    | o    | o    | o       | o    | o     |
| **exec**      | o     | o    | o   | o   | o    | o    | o    | o       | o    | o     |
| **exit**      | o     | o    | o   | o   | o    | o    | o    | o       | o    | o     |
| **export**    | o     | o    | o   | o   | o    | o    | o    | o       | o    | o     |
| **false**     | o     | o    | o   | o   | o    | o    | o    | o       | o    | o     |
| fc            | ~~o~~ | o    | o   | -   | o    | -    | o    | -       | o    | o     |
| fg            | o     | o    | o   | o   | o    | -    | o    | o       | o    | o     |
| ------------- | dash  | bash | zsh | ksh | mksh | posh | yash | busybox | bosh | pbosh |
| float         | -     | -    | o   | -   | -    | -    | -    | -       | -    | -     |
| functions     | -     | -    | o   | -   | -    | -    | -    | -       | -    | -     |
| getcap        | -     | -    | o   | -   | -    | -    | -    | -       | -    | -     |
| getconf       | -     | -    | -   | o   | -    | -    | -    | -       | -    | -     |
| getln         | -     | -    | o   | -   | -    | -    | -    | -       | -    | -     |
| getops        | o     | o    | o   | o   | o    | o    | o    | -       | -    | -     |
| global        | -     | -    | -   | -   | o    | -    | -    | -       | -    | -     |
| hash          | o     | o    | o   | -   | o    | -    | o    | o       | o    | o     |
| help          | -     | o    | -   | -   | -    | -    | o    | o       | -    | -     |
| hist          | -     | -    | -   | o   | -    | -    | -    | -       | -    | -     |
| history       | -     | o    | o   | -   | -    | -    | o    | o       | o    | o     |
| integer       | -     | -    | o   | -   | -    | -    | -    | -       | -    | -     |
| jobs          | o     | o    | o   | o   | o    | -    | o    | o       | o    | o     |
| **kill**      | o     | o    | o   | o   | o    | o    | o    | o       | o    | o     |
| let           | ~~o~~ | o    | o   | o   | o    | -    | -    | o       | -    | -     |
| limit         | -     | -    | o   | -   | -    | -    | -    | -       | o    | -     |
| local         | o     | o    | o   | -   | -    | o    | -    | o       | o    | -     |
| log           | -     | -    | o   | -   | -    | -    | -    | -       | -    | -     |
| logout        | -     | o    | o   | -   | -    | -    | -    | -       | -    | -     |
| mapfile       | -     | o    | -   | -   | -    | -    | -    | -       | -    | -     |
| ------------- | dash  | bash | zsh | ksh | mksh | posh | yash | busybox | bosh | pbosh |
| mknod         | -     | -    | -   | -   | o    | -    | -    | -       | -    | -     |
| newgrp        | -     | -    | -   | o   | -    | -    | -    | -       | o    | o     |
| noglob        | -     | -    | o   | -   | -    | -    | -    | -       | -    | -     |
| popd          | -     | o    | o   | -   | -    | -    | o    | -       | o    | -     |
| print         | -     | -    | o   | o   | o    | -    | -    | -       | -    | -     |
| printf        | o     | o    | o   | o   | -    | -    | o    | o       | o    | o     |
| pushed        | -     | o    | o   | -   | -    | -    | o    | -       | -    | -     |
| pushln        | -     | -    | o   | -   | -    | -    | -    | -       | -    | -     |
| **pwd**       | o     | o    | o   | o   | o    | o    | o    | o       | o    | o     |
| r             | -     | -    | o   | -   | -    | -    | -    | -       | -    | -     |
| **read**      | o     | o    | o   | o   | o    | o    | o    | o       | o    | o     |
| readarray     | -     | o    | -   | -   | -    | -    | -    | -       | -    | -     |
| **readonly**  | o     | o    | o   | o   | o    | o    | o    | o       | o    | o     |
| realpath      | -     | -    | -   | -   | o    | -    | -    | -       | -    | -     |
| rehash        | -     | -    | o   | -   | -    | -    | -    | -       | -    | -     |
| rename        | -     | -    | -   | -   | o    | -    | -    | -       | -    | -     |
| **return**    | o     | o    | o   | o   | o    | o    | o    | o       | o    | o     |
| sched         | -     | -    | o   | -   | -    | -    | -    | -       | -    | -     |
| **set**       | o     | o    | o   | o   | o    | o    | o    | o       | o    | o     |
| setcap        | -     | -    | o   | -   | -    | -    | -    | -       | -    | -     |
| ------------- | dash  | bash | zsh | ksh | mksh | posh | yash | busybox | bosh | pbosh |
| setopt        | -     | -    | o   | -   | -    | -    | -    | -       | -    | -     |
| **shift**     | o     | o    | o   | o   | o    | o    | o    | o       | o    | o     |
| shopt         | -     | o    | -   | -   | -    | -    | -    | -       | -    | -     |
| sleep         | -     | -    | -   | o   | o    | -    | -    | -       | -    | -     |
| source        | -     | o    | o   | -   | o    | -    | -    | o       | -    | -     |
| stat          | -     | -    | o   | -   | -    | -    | -    | -       | -    | -     |
| suspend       | -     | o    | o   | -   | o    | -    | o    | -       | o    | o     |
| **test**      | o     | o    | o   | o   | o    | o    | o    | o       | o    | o     |
| time          | -     | o    | o   | o   | o    | -    | -    | -       | o    | -     |
| **times**     | o     | o    | o   | o   | o    | o    | o    | o       | o    | o     |
| **trap**      | o     | o    | o   | o   | o    | o    | o    | o       | o    | o     |
| **true**      | o     | o    | o   | o   | o    | o    | o    | o       | o    | o     |
| ttyctl        | -     | -    | o   | -   | -    | -    | -    | -       | -    | -     |
| type          | o     | o    | o   | o   | o    | -    | o    | o       | -    | -     |
| typeset       | -     | o    | o   | o   | o    | -    | o    | -       | -    | -     |
| ulimit        | o     | o    | o   | o   | o    | -    | o    | o       | o    | o     |
| **umask**     | o     | o    | o   | o   | o    | o    | o    | o       | o    | o     |
| unalias       | o     | o    | o   | o   | o    | -    | o    | o       | o    | o     |
| unfunction    | -     | -    | o   | -   | -    | -    | -    | -       | -    | -     |
| unhash        | -     | -    | o   | -   | -    | -    | -    | -       | -    | -     |
| ------------- | dash  | bash | zsh | ksh | mksh | posh | yash | busybox | bosh | pbosh |
| unlimit       | -     | -    | o   | -   | -    | -    | -    | -       | -    | -     |
| **unset**     | o     | o    | o   | o   | o    | o    | o    | o       | o    | o     |
| unsetopt      | -     | -    | o   | -   | -    | -    | -    | -       | -    | -     |
| vared         | -     | -    | o   | -   | -    | -    | -    | -       | -    | -     |
| **wait**      | o     | o    | o   | o   | o    | o    | o    | o       | o    | o     |
| whence        | -     | -    | o   | o   | o    | -    | -    | -       | -    | -     |
| where         | -     | -    | o   | -   | -    | -    | -    | -       | -    | -     |
| which         | -     | -    | o   | -   | -    | -    | -    | -       | -    | -     |
