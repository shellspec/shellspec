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
  echo 'PATH="${SHELLSPEC_PATH:?}"'
  echo 'export PATH'
  echo "$1" '"$@"'
}

__ main __

if [ ! -e "$SHELLSPEC_SPECDIR" ]; then
  echo "Not a shellspec directory"
  exit 1
fi

mkdir -p "$SHELLSPEC_SUPPORT_BINDIR"

for cmd; do
  bin="$SHELLSPEC_SUPPORT_BINDIR/$cmd"
  if [ -e "$bin" ]; then
    echo "Skip, $cmd already exist (${SHELLSPEC_SUPPORT_BINDIR#"$PWD/"}/$cmd)"
  else
    generate "${cmd#@}" > "$bin"
    chmod +x "$bin"
    echo "Generate $cmd (${bin#"$PWD/"})"
  fi
done
