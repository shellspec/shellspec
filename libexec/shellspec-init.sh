#!/bin/sh

set -eu

test || __() { :; }

generate() {
  if [ -e "$1" ]; then
    set -- exist "$1"
  else
    case "$1" in (*/*)
      mkdir -p "${1%/*}"
    esac
    cat > "$1"
    set -- create "$1"
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
    git ) ignore_file "/" | generate ".gitignore" ;;
    hg  ) ignore_file "^" "syntax: regexp" | generate ".hgignore" ;;
    svn ) ignore_file "/" | generate ".svnignore" ;;
  esac
done
