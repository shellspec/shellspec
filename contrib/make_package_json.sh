#!/bin/sh

version() {
  ./shellspec --version
}

files() {
  echo "["
  files="$(find lib libexec -type f -exec echo "    \"{}\"," \;)"
  echo "${files%,}"
  echo "  ]"
}

cat<<JSON
{
  "name": "shellspec",
  "version": "$(version)",
  "description": "BDD style unit testing framework for POSIX compliant shell script",
  "scripts": ["shellspec"],
  "files": $(files),
  "install": "make install"
}
JSON
