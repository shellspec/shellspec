#!/bin/sh

version() {
  ./shellspec --version
}

files() {
  echo "["
  files="$(find bin lib libexec -type f,l -exec echo "    \"{}\"," \;)"
  echo "${files%,}"
  echo "  ]"
}

cat<<JSON
{
  "name": "shellspec",
  "version": "$(version)",
  "description": "BDD style unit testing framework for POSIX compliant shell script",
  "homepage": "https://shellspec.info",
  "scripts": ["shellspec"],
  "license": "MIT",
  "repository": "github:shellspec/shellspec",
  "files": $(files),
  "install": "make install",
  "bin": {
    "shellspec": "bin/shellspec"
  }
}
JSON
