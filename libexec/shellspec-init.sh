#!/bin/sh

set -eu

test || __() { :; }

generate() {
  file="$1" && shift
  if [ -e "$file" ]; then
    set -- exist "$file"
  else
    case "$file" in (*/*)
      mkdir -p "${file%/*}"
    esac
    [ $# -eq 0 ] && set -- "$(cat)"
    printf '%s\n' "$@" > "$file"
    set -- create "$file"
  fi
  printf '%8s   %s\n' "$@"
}

ignore_file() {
  [ "${2:-}" ] && echo "$2"
  echo "${1:-}.shellspec-local"
  echo "${1:-}.shellspec-quick.log"
  echo "${1:-}report/"
  echo "${1:-}coverage/"
}

${__SOURCED__:+return}

__ main __

generate ".shellspec" <<DATA
--require spec_helper

## Default kcov (coverage) options
# --kcov-options "--include-path=. --path-strip-level=1"
# --kcov-options "--include-pattern=.sh"
# --kcov-options "--exclude-pattern=/.shellspec,/spec/,/coverage/,/report/"

## Example: Include script "myprog" with no extension
# --kcov-options "--include-pattern=.sh,myprog"

## Example: Only specified files/directories
# --kcov-options "--include-pattern=myprog,/lib/"
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

for template; do
  case $template in
    git ) generate ".gitignore" "$(ignore_file "/")" ;;
    hg  ) generate ".hgignore" "$(ignore_file "^" "syntax: regexp")" ;;
    svn ) generate ".svnignore" "$(ignore_file "/")" ;;
  esac
done
