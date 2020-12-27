#!/bin/sh

# NOTE: This file must be compatible with the Bourne shell,
# because /bin/sh can be the Bourne shell.

# Workaround for ksh. Remove readonly flag inherited to child process
if [ "${SHELLSPEC_PATH_IS_READONLY:-}" ]; then
  if [ ! "$SHELLSPEC_PATH_IS_READONLY" = "-" ]; then
    SHELLSPEC_PATH_IS_READONLY="-"
    # shellcheck disable=SC2086
    exec $SHELLSPEC_SHELL "$0" "$@"
  fi
  # shellcheck disable=SC2039
  typeset +x PATH
  exec "$SHELLSPEC_ENV" PATH="$PATH" SHELLSPEC_PATH_IS_READONLY="" "$0" "$@"
fi

PATH="${SHELLSPEC_PATH:?}"
export PATH

invoke() {
  cmd=$1
  shift

  if [ ! "$SHELLSPEC_BUSYBOX_W32" ]; then
    [ "${ZSH_VERSION:-}" ] && setopt shwordsplit
    OLDIFS=$IFS && IFS=":"
    for p in $PATH; do
      [ -x "$p/$cmd" ] && cmd="$p/$cmd" && break
    done
    IFS=$OLDIFS
  fi

  "$cmd" "$@"
}
