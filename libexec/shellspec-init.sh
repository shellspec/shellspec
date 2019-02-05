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
DATA

generate "spec/spec_helper.sh" <<DATA
#shellcheck shell=sh

# set -eu

# shellspec_mockable function_name

shellspec_spec_helper_configure() {
  # shellspec_import 'support/custom_matcher'
  :
}
DATA
