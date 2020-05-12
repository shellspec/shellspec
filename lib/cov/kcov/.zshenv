#!/bin/zsh
#ENV export ZDOTDIR="$SHELLSPEC_LIB/cov/kcov"

trap '
  if [ ${#funcsourcetrace[@]} -gt 0 ]; then
    echo kcov@${funcsourcetrace[1]%:*}@$((${funcsourcetrace[1]##*:}+LINENO))@
  else
    echo kcov@${0}@${LINENO}@
  fi >&$KCOV_BASH_XTRACEFD
' DEBUG
