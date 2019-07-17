#!/bin/sh

test || __() { :; }

readonly installer="https://git.io/shellspec"
readonly repo="https://github.com/shellspec/shellspec.git"
readonly archive="https://github.com/shellspec/shellspec/archive"
readonly project="shellspec"
readonly exec="shellspec"

{ set -eu; eval "usage() { echo \"$(cat)\"; }"; } << USAGE
Usage: [sudo] ./${0##*/} [VERSION] [OPTIONS...]
  or : wget -O- $installer | [sudo] sh
  or : wget -O- $installer | [sudo] sh -s -- [OPTIONS...]
  or : wget -O- $installer | [sudo] sh -s VERSION [OPTIONS...]
  or : curl -fsSL $installer | [sudo] sh
  or : curl -fsSL $installer | [sudo] sh -s -- [OPTIONS...]
  or : curl -fsSL $installer | [sudo] sh -s VERSION [OPTIONS...]

VERSION:
  Specify install version and method

  e.g
    1.0.0           Install 1.0.0 from git
    master          Install master from git
    1.0.0.tar.gz    Install 1.0.0 from tar.gz archive
    .               Install from local directory

OPTIONS:
  -p, --prefix PREFIX   Specify prefix                 [default: \\\$HOME]
  -b, --bin BIN         Specify bin directory          [default: <PREFIX>/bin]
  -d, --dir DIR         Specify installation directory [default: <PREFIX>/opt/$project]
  -s, --switch          Switch version (requires installed via git)
  -l, --list            List available versions (tags)
      --pre             Include pre-release
      --fetch FETCH     Force command to use when install from archive (curl or wget)
  -y, --yes             Automatic yes to prompts
  -h, --help            You're looking at it
USAGE

[ "${ZSH_VERSION:-}" ] && setopt shwordsplit

finish() { done=1; exit "${1:-0}"; }
error() { printf '\033[31m%s\033[0m\n' "$1"; }
abort() { [ "${1:-}" ] && error "$1" >&2; finish 1; }
finished() { [ "$done" ] || error "Failed to install"; }

exists() {
  ( IFS=:; for p in $PATH; do [ -x "${p%/}/$1" ] && return 0; done; return 1 )
}

prompt() {
  ans=${2:-} && printf '%s' "$1"
  [ "$ans" ] && echo "$2"
  [ "$ans" ] || read -r ans
  ! case $ans in ( [Yy] | [Yy][Ee][Ss] ) false; esac
}

fetch() {
  tmpfile=$(mktemp)
  case $FETCH in
    curl) curl --head -sSfL -o /dev/null "$1" && curl -SfL "$1" ;;
    wget) wget --spider -q "$1" && wget -O- "$1" ;;
  esac > "$tmpfile" &&:
  error=$?
  if [ "$error" -eq 0 ]; then
    unarchive "$tmpfile" "$2" &&:
    error=$?
    [ "$error" -ne 0 ] && [ -d "$2" ] && rm -rf "$2"
  fi
  rm "$tmpfile"
  return "$error"
}

unarchive() {
  mkdir -p "$2"
  tar x -z --strip-components 1 -f "$1" -C "$2"
}

git_remote_tags() {
  git ls-remote --tags "$repo" | while read -r line; do
    tag=${line##*/} && pre=${tag#${tag%%[-+]*}}
    [ "${1:-}" = "--pre" ] || case $pre in (-*) continue; esac
    echo "$tag"
  done
}

get_versions() {
  git_remote_tags "${PRE:+--pre}"
}

version_sort() {
  while read -r version; do
    ver=${version%%+*} && num=${ver%%-*} && pre=${ver#$num}
    #shellcheck disable=SC2086
    IFS=. && set -- $num
    printf '%08d%08d%08d%08d' "${1:-0}" "${2:-0}" "${3:-0}" "${4:-0}"
    printf '%s %s\n' "${pre:-=}" "$version"
  done | LC_ALL=C sort -k 1 | while read -r kv; do echo "${kv#* }"; done
}

join() {
  s=''
  while read -r v; do
    s="$s$v$1"
  done
  echo "${s%"$1"}"
}

last() {
  version=''
  while read -r v; do
    version=$v
  done
  echo "$version"
}

list_versions() {
  get_versions | version_sort | join ", "
}

latest_version() {
  get_versions | version_sort | last
}

${__SOURCED__:+return}

trap finished EXIT
VERSION='' PREFIX=$HOME BIN='' DIR='' SWITCH='' PRE='' YES='' FETCH='' done=''

__ parse_option __

while [ $# -gt 0 ]; do
  case $1 in
    -p | --prefix ) [ "${2:-}" ] || abort "PREFIX not specified"
                    PREFIX=$2 && shift ;;
    -b | --bin    ) [ "${2:-}" ] || abort "BIN not specified"
                    BIN=$2 && shift ;;
    -d | --dir    ) [ "${2:-}" ] || abort "DIR not specified"
                    DIR=$2 && shift ;;
    -s | --switch ) SWITCH=1 ;;
    -y | --yes    ) YES=y ;;
    -l | --list   ) list_versions && finish ;;
         --pre    ) PRE=1 ;;
         --fetch  ) [ "${2:-}" ] || abort "FETCH not specified"
                    case $2 in ( curl | wget ) FETCH=$2 && shift ;;
                      *) abort "FETCH must be 'curl' or 'wget'."
                    esac ;;
    -h | --help   ) usage && finish ;;
    -*            ) abort "Unknown option $1" ;;
    *             ) VERSION=$1 ;;
  esac
  shift
done

BIN=${BIN:-${PREFIX%/}/bin} DIR=${DIR:-${PREFIX%/}/opt/$project}

__ main __

case $VERSION in
  .)
    method=local DIR=$PWD
    [ -x "$DIR/$exec" ] || abort "Not found '$exec' in installation directory: '$DIR'"
    VERSION=$("$DIR/$exec" --version)
    ;;
  *.tar.gz)
    [ "$SWITCH" ] && abort "Can not switch version when install from archive"
    [ -e "$DIR" ] && abort "Already exists installation directory: '$DIR'"
    method=archive
    [ ! "$FETCH" ] && exists curl && FETCH=curl
    [ ! "$FETCH" ] && exists wget && FETCH=wget
    [ "$FETCH" ] || abort "Requires 'curl' or 'wget' when install from archive"
    exists tar || abort "Not found 'tar' when install from archive"
    ;;
  *)
    if [ "$SWITCH" ]; then
      method=switch
      [ -d "$DIR" ] || abort "Not found installation directory: '$DIR'"
      [ -d "$DIR/.git" ] || abort "Can't switch it's not a git repository: '$DIR'"
    else
      method=git
      [ -e "$DIR" ] && abort "Already exists installation directory: '$DIR'"
    fi
    # requires git >= 1.7.10.4
    exists git || abort "Requires 'git' when install from git repository"
    [ "$VERSION" ] || VERSION=$(latest_version)
esac

echo "Executable file        : $BIN/$exec"
echo "Installation directory : $DIR"
echo "Version (tag or commit): $VERSION"
case $method in
  git) echo "[git] $repo" ;;
  archive) echo "[$FETCH] $archive/$VERSION" ;;
esac
echo

prompt "Do you want to continue? [y/N] " "$YES" < /dev/tty || abort "Canceled"

case $method in
  git)
    git init "$DIR" && cd "$DIR"
    git remote add origin "$repo"
    git fetch --depth=1 origin "$VERSION"
    git checkout -b "$VERSION" FETCH_HEAD
    ;;
  archive)
    fetch "$archive/$VERSION" "$DIR"
    ;;
  switch)
    cd "$DIR"
    if message=$(git checkout "$VERSION" 2>&1); then
      echo "$message"
    else
      git fetch --depth=1 origin "$VERSION"
      git checkout -b "$VERSION" FETCH_HEAD
    fi
    ;;
  local) # Do nothing
esac

mkdir -p "$BIN"
ln -sf "$DIR/$exec" "$BIN/$exec"

if [ ! -L "$BIN/$exec" ]; then
  rm "$BIN/$exec"
  printf '#!/bin/sh\nexec "%s" "$@"\n' "$DIR/$exec" > "$BIN/$exec"
  chmod +x "$BIN/$exec"
fi

echo "Done"
finish
