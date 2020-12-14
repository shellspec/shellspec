#!/bin/sh

set -eu

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"

test || __() { :; }

# shellcheck disable=SC2016
generate() {
  echo "#!/bin/sh -e"
  echo ". \"\$SHELLSPEC_SUPPORT_BIN\""
  echo "invoke $1 \"\$@\""
}

__ main __

if [ ! -e "$SHELLSPEC_HELPERDIR" ]; then
  abort "shellspec helper directory not found: $SHELLSPEC_HELPERDIR"
fi

mkdir -p "$SHELLSPEC_SUPPORT_BINDIR"

for cmd; do
  bin="$SHELLSPEC_SUPPORT_BINDIR/$cmd"
  if [ -e "$bin" ]; then
    warn "Skip, $cmd already exist (${SHELLSPEC_SUPPORT_BINDIR#"$PWD/"}/$cmd)"
  else
    generate "${cmd#@}" > "$bin"
    chmod +x "$bin"
    echo "Generate $cmd (${bin#"$PWD/"})"
  fi
done
