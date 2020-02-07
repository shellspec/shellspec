#!/bin/sh

set -eu

log() {
  printf '%8s   %s\n' "$1" "$2"
}

generate() {
  if [ -e "$1" ]; then
    log exist "$1"
  else
    case "$1" in (*/*)
      mkdir -p "${1%/*}"
    esac
    : > "$1"
    while IFS= read -r line; do
      echo "$line" >> "$1"
    done
    log create "$1"
  fi
}

generate ".shellspec" <<DATA
--require spec_helper
# --kcov-options "--include-path=. --include-pattern=.sh --exclude-pattern=/spec/,/coverage/,/report/"
DATA

generate "spec/spec_helper.sh" <<DATA
#shellcheck shell=sh

# set -eu

# shellspec_spec_helper_configure() {
#   shellspec_import 'support/custom_matcher'
# }
DATA

generate "spec/${SHELLSPEC_PROJECT_NAME}_spec.sh" <<'DATA'
Describe "Sample specfile"
  Describe "hello()"
    hello() {
      echo # "hello $1"
    }

    It "puts greeting, but not implemented"
      Pending "You should implement hello function"
      When call hello world
      The output should eq "hello world"
    End
  End
End
DATA
