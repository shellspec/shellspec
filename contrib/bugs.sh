#!/bin/sh

# Bugs and compatibility check for shell

# This script is for development purposes.
# It provide as is, do not any support.
# It may change without notice.

# Example of use
#   contrib/bugs.sh
#   bash contrib/bugs.sh
#   contrib/test_in_docker.sh [Dockerfile] -- bash contrib/bugs.sh

affect()      { echo "[affect] $title"; }
no_problem()  { echo "[------] $title"; }
skip()        { echo "[skip  ] $title [skip reason: $1]"; }

(
  title="01: set -e option is reset (posh)"
  set -eu
  foo() { eval 'return 0'; }
  foo
  case $- in
    *e*) no_problem ;;
    *) affect ;;
  esac
)

(
  title="02: double quoted string treated as a pattern (posh)"
  string="abc[d]"
  pattern="c[d]"
  case $string in
    *"$pattern"*) no_problem ;;
    *) affect ;;
  esac
)

(
  title="03: @: parameter not set (posh, ksh <= around 93s)"
  if (set -u; : "$@") 2>/dev/null; then no_problem; else affect; fi
)

return_true() { false; }
(
  title="04: function not overrite (ksh)"
  return_true() { true; }
  if return_true; then no_problem; else affect; fi
)

(
  title="05: exit not return exit code (zsh <= around 4.2.5)"
  foo() { (exit 123) &&:; }; foo
  if [ $? -eq 123 ]; then no_problem; else affect; fi
)

(
  title="06: abort if unset not the defined variable (bash <= around 2.05a, zsh <= around 4.2.5, ksh <= around 93s)"
  ok=$(
    set -e
    unset not_defined_variable
    echo 1
  )
  if [ "$ok" ]; then no_problem; else affect; fi
)

(
  title="07: limited arithmetic expansion (dash <= around 0.5.4, old ash)"
  i=0
  ok=$(eval 'i=$((i+1))' 2>/dev/null; echo 1)
  if [ "$ok" ]; then no_problem; else affect; fi
)

(
  title="08: Unsupported trap (posh: around 0.8.5)"
  if (trap '' INT) 2>/dev/null; then no_problem; else affect; fi
)

(
  title="09: different split by IFS (zsh, posh <= around 0.6.13)"
  [ "${ZSH_VERSION:-}" ] && emulate -R sh
  string="1,2,"
  IFS=','
  set -- $string
  if [ $# -eq 2 ]; then no_problem; else affect; fi
)

(
  title="10: variable reference in the same line (dash <= around 0.5.5)"
  i=1
  i=$(($i+1)) j=$i
  if [ "$j" -eq 2 ]; then no_problem; else affect; fi
)

(
  title="11: command time -p output LF at first (solaris)"
  if (command time echo) >/dev/null 2>/dev/null; then
    command time -p printf '' 2>&1 | {
      IFS= read -r line
      if [ "$line" ]; then no_problem; else affect; fi
    }
  else
    skip 'time command not found'
  fi
)

(
  title="12: cat not ignore set -e (zsh = around 5.4.2)"
  (
    set -e
    nagative() { false; }
    if false; then :; else nagative && : || :; fi
  )
  [ $? -eq 0 ] && no_problem || affect
)

(
  title="13: many unset cause a Segmentation fault (mksh = around 39)"
  (
    i=0
    while [ $i -lt 30000 ]; do
      unset v ||:
      i=$(($i+1))
    done
  ) 2>/dev/null
  [ $? -eq 0 ] && no_problem || affect
)

(
  title="14: here document does not expand parameters (ash = around 0.3.8)"
  set -- value
  foo() { cat; }
  result=$(foo<<HERE
$1
HERE
  )
  [ "$result" = value ] && no_problem || affect
)

(
  title="15: glob not working (posh <= around 0.12.6)"
  files=$(echo "/"*)
  [ "$files" != "/*" ] && no_problem || affect
)

(
  title="16: 'command' can not prevent error (bash = 2.03)"
  ret=$(
    set -e
    command false &&:
    echo ok
  )
  [ "$ret" = "ok" ] && no_problem || affect
)

(
  title="17: can not return within eval (posh = around 2.36)"
  foo() {
    eval 'return 0'
    return 1
  }
  foo &&:
  [ $? -eq 0 ] && no_problem || affect
)

(
  title="18: do not glob with set -u (posh = around 0.10.2)"
  set -u
  [ "$(echo /*)" != "/*" ]
  [ $? -eq 0 ] && no_problem || affect
)

(
  title='19: can not get $POSH_VERSION (posh = around 0.8.5)'
  if [ "${POSH_VERSION:-}" ]; then
    [ "$POSH_VERSION" != "POSH_VERSION" ]
    [ $? -eq 0 ] && no_problem || affect
  else
    skip 'this shell is not posh'
  fi
)

(
  title='20: do not remove leading space when read with one arguments (yash = around 2.36)'
  IFS=' '
  read -r line<<HERE
    line
HERE
  [ "$line" = "line" ]
  [ $? -eq 0 ] && no_problem || affect
)

(
  title='21: cat not ignore set -e with eval (pdksh = around 5.2.14 on debian 3.0)'
  ret=$(
    set -e
    foo() {
      eval "false"
      echo ok
    }
    foo ||:
  )
  [ "$ret" = "ok" ] && no_problem || affect
)

(
  title='22: internal error: j_async: bad nzombie (0) (posh = around 0.6.13)'
  file=$(mktemp tmp.XXXXXXXXXX)
  (
    sleep 0 &
    wait $!
  ) 2>"$file"
  ret=$(cat "$file")
  rm "$file"

  case $ret in
    *bad\ nzombie*) affect ;;
    *) no_problem ;;
  esac
)

(
  title='23: can not read after reading null character (yash = around 2.46)'
  file=$(mktemp tmp.XXXXXXXXXX)
  printf 'foo\0bar' > "$file"
  IFS= read -r ret < "$file"
  IFS= read -r ret <<HERE
AAA
HERE
  rm "$file"
  [ "$ret" ] && no_problem || affect
)

(
  title='24: variable expansion not working with the positional parameter (posh, pdksh)'
  set -- 'foobar' 'bar'
  [ "${1%$2}" = "foo" ] && no_problem || affect
)

(
  title='25: printf can not handle octal numbers correctly (old pdksh, zsh <= around 4.0.4)'
  # zsh 4.2.5: ch=\101
  # pdksh on debian 3.0: \1: invalid escape
  ch=$(printf "\101" 2>/dev/null) ||:
  [ "$ch" = "A" ] && no_problem || affect
)

echo Done
