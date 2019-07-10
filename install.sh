#!/bin/sh

readonly installer="https://git.io/shellspec"
readonly repo="https://github.com/shellspec/shellspec.git"
readonly archive="https://github.com/shellspec/shellspec/archive"
readonly project="shellspec"
readonly exec="shellspec"

{ set -eu; eval "usage() { done=1; echo \"$(cat)\"; }"; } << USAGE
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
  -p, --prefix PREFIX   Specify prefix          [default: \\\$HOME]
  -b, --bin BIN         Specify bin directory   [default: <PREFIX>/bin]
  -d, --dir DIR         Specify directory name  [default: .$project]
  -s, --switch          Switch version (requires installed via git)
  -l, --list            List available versions (tags)
      --pre             Include pre-release
      --fetch FETCH     Force command to use when install from archive (curl or wget)
  -y, --yes             Automatic yes to prompts
  -h, --help            You're looking at it
USAGE

VERSION='' PREFIX=$HOME BIN='' DIR=.$project  SWITCH=''  PRE='' YES='' FETCH=''
done=''

finished() {
  [ "$done" ] || error "Failed to install"
}
trap finished EXIT

error() { printf '\033[31m%s\033[0m\n' "$1"; }

abort() { done=1; error "$1" >&2; exit 1; }

exists() {
  ( IFS=:; for p in $PATH; do [ -x "${p%/}/$1" ] && exit 0; done; exit 1 )
}

fetch() {
  case $FETCH in
    curl) curl -sSfLI -o /dev/null "$1" && curl -SfL "$1" | unarchive "$2" ;;
    wget) wget -q --spider "$1" && wget -O- "$1" | unarchive "$2" ;;
  esac &&:
  error=$?
  [ "$error" -gt 0 ] && [ -d "$DIR" ] && rmdir "$DIR"
  return "$error"
}

unarchive() {
  mkdir "$1"
  tar xzf - -C "$1" --strip-components 1
}

git_remote_tags() {
  git ls-remote --tags "$repo" | while read -r line; do
    tag=${line##*/} && ver=${tag%%+*} && num=${ver%%-*} && rel=${ver#"$num"}
    [ "$PRE" ] || case $rel in -*) continue; esac
    IFS=. && eval 'set -- $num'
    printf '%08d%08d%08d%s %s\n' "$1" "$2" "$3" "${rel:-=}" "$tag"
  done | sort -k 1 "$@" | while read -r line; do echo "${line#* }"; done
}

latest_version() {
  git_remote_tags -r | { read -r line; echo "$line"; }
}

list_versions() {
  git_remote_tags | {
    versions=$(while read -r ver; do printf '%s, ' "$ver"; done)
    echo "${versions%, }"
  }
}

while [ $# -gt 0 ]; do
  case $1 in
    -p | --prefix ) [ "${2:-}" ] || abort "PREFIX not specified"
                    PREFIX=$2 && shift ;;
    -b | --bin    ) [ "${2:-}" ] || abort "BIN not specified"
                    BIN=$2 && shift ;;
    -d | --dir    ) [ "${2:-}" ] || abort "DIR not specified"
                    DIR=$2 && shift ;;
    -s | --switch ) SWITCH=1 ;;
    -y | --yes    ) YES=1 ;;
    -l | --list   ) list_versions && exit ;;
         --fetch  ) [ "${2:-}" ] || abort "FETCH not specified"
                    case $2 in
                      curl | wget) FETCH=$2 && shift ;;
                      *) abort "FETCH must be 'curl' or 'wget'."
                    esac
                    ;;
    -h | --help   ) usage && exit ;;
    -*            ) abort "Unknown option $1" ;;
    *             ) VERSION=$1 ;;
  esac
  shift
done

BIN=${BIN:-${PREFIX%/}/bin} DIR=${PREFIX%/}/$DIR

case $VERSION in
  .)
    method=local DIR=$PWD
    [ -d "$DIR" ] || abort "Not found projct directory: '$DIR'"
    [ -x "$DIR/$exec" ] || abort "Not found '$exec' in project directory: '$DIR'"
    VERSION=$("$DIR/$exec" --version)
    ;;
  *.tar.gz)
    [ "$SWITCH" ] && abort "Can not switch version when install from archive"
    [ -e "$DIR" ] && abort "Already exists projct directory: '$DIR'"
    method=archive
    [ ! "$FETCH" ] && exists curl && FETCH=curl
    [ ! "$FETCH" ] && exists wget && FETCH=wget
    [ "$FETCH" ] || abort "Requires 'curl' or 'wget' when install from archive"
    exists tar || abort "Not found 'tar' when install from archive"
    ;;
  *)
    if [ "$SWITCH" ]; then
      method=switch
      [ -d "$DIR" ] || abort "Not found projct directory: '$DIR'"
      [ -d "$DIR/.git" ] || abort "Can't switch it's not a git repository: '$DIR'"
    else
      method=git
      [ -e "$DIR" ] && abort "Already exists projct directory: '$DIR'"
    fi
    # requires git >= 1.7.10.4
    exists git || abort "Requires 'git' when install from git repository"
    [ "$VERSION" ] || VERSION=$(latest_version)
esac

echo "Executable file  : $BIN/$exec"
echo "Project directory: $DIR"
echo "Version          : $VERSION"
case $method in
  git) echo "[git] $repo" ;;
  archive) echo "[$FETCH] $archive/$VERSION" ;;
esac

printf '\n%s' "Do you want to continue? [y/N] "
ans=''
[ "$YES" ] && ans=y && echo "$ans"
[ "$ans" ] || read -r ans < /dev/tty
case $ans in [Yy]|[Yy][Ee][Ss]) ;; *) done=1; exit 1; esac

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
  local) ;; # Do nothing
esac

mkdir -p "$BIN"
ln -sf "$DIR/$exec" "$BIN/$exec"

[ -L "$BIN/$exec" ] && done=1 && exit

rm "$BIN/$exec"
cat << HERE > "$BIN/$exec"
#!/bin/sh
exec "$DIR/$exec" "\$@"
HERE
chmod +x "$BIN/$exec"

done=1
