#!/bin/sh -eu

run() {
  echo "$@"
  "$@"
}

confirm() {
  printf "%s [y/N] " "$1"
  read -r ans
  case $ans in ([yY] | [yY][eE][sS]) return; esac
  return 1
}

is_prerelease() {
  case $1 in (*-*) return; esac
  return 1
}

version=$(./shellspec --version)

confirm "Release $version?" || exit 0
run git tag -a "$version" -m "$version"
run git push origin "$version"

is_prerelease "$version" && exit 0

confirm "Update $version to latest?" || exit 0
run git tag -f latest "$version"
run git push -f origin latest
