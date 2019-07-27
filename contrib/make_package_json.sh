#!/bin/sh

version() {
  ./shellspec --version
}

files() {
  echo "["
  files="$(find bin lib libexec \( -type f -o -type l \) -exec echo "    \"{}\"," \; | sort)"
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
  "files": $(files),
  "install": "make install"
}
JSON
