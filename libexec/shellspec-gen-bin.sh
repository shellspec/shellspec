#!/bin/sh

set -eu

test || __() { :; }

# shellcheck disable=SC2016
generate() {
  echo '#!/bin/sh -e'
  echo 'if [ "${SHELLSPEC_PATH_IS_READONLY:-}" ]; then'
  echo '  typeset +x PATH'
  echo '  exec "$SHELLSPEC_ENV" PATH="$PATH" SHELLSPEC_PATH_IS_READONLY="" "$0" "$@"'
  echo 'fi'
  echo 'export PATH="${SHELLSPEC_PATH:?}"'
  echo 'cmd="${0##*/}"'
  echo '"${cmd#@}" "$@"'
}

__ main __

if [ ! -e "$SHELLSPEC_SPECDIR" ]; then
  echo "Not a shellspec directory"
  exit 1
fi

mkdir -p "$SHELLSPEC_SUPPORT_BIN"

for cmd; do
  bin="$SHELLSPEC_SUPPORT_BIN/$cmd"
  if [ -e "$bin" ]; then
    echo "Skip, $cmd already exist (${SHELLSPEC_SUPPORT_BIN#"$PWD/"}/$cmd)"
  else
    generate > "$bin"
    chmod +x "$bin"
    echo "Generate $cmd (${bin#"$PWD/"})"
  fi
done
