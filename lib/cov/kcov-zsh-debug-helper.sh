#shellcheck shell=bash disable=SC2154
trap '
  if [ ${#funcsourcetrace[@]} -gt 0 ]; then
    echo kcov@${funcsourcetrace[1]%:*}@$((${funcsourcetrace[1]##*:}+LINENO))@
  else
    echo kcov@${0}@${LINENO}@
  fi >&$KCOV_BASH_XTRACEFD
' DEBUG
