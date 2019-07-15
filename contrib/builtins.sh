#!/bin/sh

# Detect builtin commands

# This script is for development purposes.
# It provide as is, do not any support.
# It may change without notice.

set -eu

PATH=":"

check() {
  while IFS=' ' read -r cmd comment; do
    if type "$cmd" >/dev/null 2>&1; then
      if [ -x /usr/bin/printf ]; then
        /usr/bin/printf "%s " "$cmd"
      else
        /bin/printf "%s " "$cmd"
      fi
    fi
  done
  echo
}

if ! type : >/dev/null 2>&1; then
  # not implements type (posh)
  type() {
    case $1 in (. | exit | type) return 0; esac
    $1
  }
fi

check<<COMMANDS
.                 | Special Built-In
:                 | Special Built-In
[                 | All Shell Built-In
alias             | Almost Shell Built-In (not built-in: posh)
array             |
autoload          |
bg                | Almost Shell Built-In (not built-in: posh)
bind              |
bindkey           |
break             | Special Built-In
builtin           |
bye               |
caller            |
cap               |
cat               | Include Posix Utilities
cd                | All Shell Built-In
chdir             |
clone             |
command           | All Shell Built-In
comparguments     |
compcall          |
compctl           |
compdescribe      |
compfiles         |
compgroups        |
compquote         |
comptags          |
comptry           |
compvalues        |
compgen           |
complete          |
compopt           |
continue          | Special Built-In
declare           |
dirs              |
disable           |
disown            |
echo              | All Shell Built-In
echotc            |
echoti            |
emulate           |
enable            |
enum              |
eval              | Special Built-In
exec              | Special Built-In
exit              | Special Built-In
export            | Special Built-In
false             | All Shell Built-In
fc                | Include Posix Utilities
fg                | Almost Shell Built-In (not built-in: posh)
float             |
functions         |
getcap            |
getconf           | Include Posix Utilities
getln             |
getops            | Almost Shell Built-In (not built-in: busybox)
global            |
hash              | Include Posix Utilities
help              |
hist              |
history           |
integer           |
jobs              | Almost Shell Built-In (not built-in: posh)
kill              | Almost Shell Built-In (not built-in: old posh)
let               |
limit             |
local             |
log               |
logout            |
mapfile           |
mknod             |
newgrp            | Include Posix Utilities
noglob            |
popd              |
print             |
printf            | Almost Shell Built-In (not built-in: mksh, posh)
pushed            |
pushln            |
pwd               | All Shell Built-In
r                 |
read              | All Shell Built-In
readarray         |
readonly          | Special Built-In
realpath          |
rehash            |
rename            |
return            | Special Built-In
sched             |
set               | Special Built-In
setcap            |
setopt            |
shift             | Special Built-In
shopt             |
sleep             | Include Posix Utilities
source            |
stat              |
suspend           |
test              | All Shell Built-In
time              | Include Posix Utilities
times             | Special Built-In
trap              | Special Built-In
true              | All Shell Built-In
ttyctl            |
type              | Almost Shell Built-In (not built-in: posh)
typeset           |
ulimit            | Almost Shell Built-In (not built-in: posh)
umask             | All Shell Built-In
unalias           | Almost Shell Built-In (not built-in: posh)
unfunction        |
unhash            |
unlimit           |
unset             | Special Built-In
unsetopt          |
vared             |
wait              | All Shell Built-In
whence            |
where             |
which             |
zcompile          |
zformat           |
zftp              |
zle               |
zmodload          |
zparseopts        |
zprof             |
zpty              |
zregexparse       |
zsocket           |
zstyle            |
ztcp              |
COMMANDS
