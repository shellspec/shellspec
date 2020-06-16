#!/bin/sh

set -eu

# gosh: https://github.com/mvdan/sh v3.0.2 fails
umask >/dev/null

# mrsh: https://github.com/emersion/mrsh WIP 657ea07 fails
( false ) 2>/dev/null && exit 1

redefine() { echo redefine; }
if [ "$(redefine() { :; }; redefine)" = "redefine" ]; then
  # ksh
  echo "SHELLSPEC_DEFECT_REDEFINE=1"
fi

if ! (false() { :; }; false) 2>/dev/null; then
  # busybox 1.1.3
  echo "SHELLSPEC_DEFECT_BUILTIN=1"
fi

# shellcheck disable=SC2034,SC2234
if ( [ "$( ( readonly value=123 ) 2>&1 )" ] ) 2>/dev/null; then
  # pdksh 5.2.14 (debian-2.2), ksh 93q, ksh 93r
  # busybox 1.15.3, busybox 1.19.4
  echo "SHELLSPEC_DEFECT_READONLY=1"
fi

# shellcheck disable=SC2154
if (set -u; unset v ||:; : "$v") 2>/dev/null; then
  # posh 0.10.2
  echo "SHELLSPEC_DEFECT_SHELLFLAG=1"
fi

if [ ! "$(errexit() { set -e; false; :; }; errexit && echo OK)" ]; then
  # bosh 2020/04/10
  echo "SHELLSPEC_DEFECT_ERREXIT=1"
fi

# Workaround for zsh 4.2.5
zshexit() { ( exit 1 ); }
if [ "${ZSH_VERSION:-}" ] && zshexit; then
  echo "SHELLSPEC_DEFECT_ZSHEXIT=1"
fi

set +e
(set -e; subshell() { return 2; }; subshell)
if [ $? -eq 1 ]; then
  echo "SHELLSPEC_DEFECT_SUBSHELL=1"
fi
set -e

set +e
eval "set -e"
sete=$-
if [ "$sete" = "${sete%e*}" ]; then
  echo "SHELLSPEC_DEFECT_SETE=1"
fi
set -e

if (: >/dev/tty && : </dev/tty) 2>/dev/null; then
  echo "SHELLSPEC_TTY=1"
fi

if "${0%/*}/shellspec-shebang" 2>/dev/null; then
  echo "SHELLSPEC_SHEBANG_MULTIARG=1"
fi

# shellcheck disable=SC2039
if (trap '' DEBUG) 2>/dev/null; then
  echo "SHELLSPEC_DEBUG_TRAP=1"
  echo "SHELLSPEC_KCOV_COMPATIBLE_SHELL=1"
fi

PATH="${PATH:-}:/"
case $PATH in (*\;/)
  echo "SHELLSPEC_BUSYBOX_W32=1"
esac

# shellcheck disable=SC2123
PATH=""

if type shopt >/dev/null 2>&1; then
  echo "SHELLSPEC_SHOPT_AVAILABLE=1"
  # shellcheck disable=SC2039
  if shopt -s failglob 2>/dev/null; then
    echo "SHELLSPEC_FAILGLOB_AVAILABLE=1"
  fi
fi

if setopt NO_NOMATCH >/dev/null 2>&1; then
  echo "SHELLSPEC_NOMATCH_AVAILABLE=1"
fi

#shellcheck disable=SC2034
{
  if [ "$({ BASH_XTRACEFD=3; set -x; :; } 2>/dev/null 3>&1)" ]; then
    echo "SHELLSPEC_XTRACEFD_VAR=BASH_XTRACEFD"
  elif [ "$({ ZSH_XTRACEFD=3; set -x; :; } 2>/dev/null 3>&1)" ]; then
    echo "SHELLSPEC_XTRACEFD_VAR=ZSH_XTRACEFD"
  fi
} 2>/dev/null

# arithmetic expansion is also required
exit $((0))
