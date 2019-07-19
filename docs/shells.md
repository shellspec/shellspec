# Shells

## Bugs

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
