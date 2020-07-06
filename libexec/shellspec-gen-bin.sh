#!/bin/sh

set -eu

if [ ! -e "$SHELLSPEC_SPECDIR" ]; then
  echo "Not a shellspec directory"
  exit 1
fi

# shellcheck disable=SC2016
generate() {
  echo '#!/bin/sh -e'
  echo 'export PATH="${SHELLSPEC_PATH:?}"'
  echo 'cmd="${0##*/}"'
  echo '"${cmd#@}" "$@"'
}

mkdir -p "$SHELLSPEC_SUPPORT_BIN"

for cmd; do
  bin="$SHELLSPEC_SUPPORT_BIN/$cmd"
  if [ -e "$bin" ]; then
    echo "Skip, $cmd already exist (${SHELLSPEC_SUPPORT_BIN#"$PWD/"}/$cmd)"
  else
    generate > "$bin"
    echo "Generate $cmd (${bin#"$PWD/"})"
  fi
done
