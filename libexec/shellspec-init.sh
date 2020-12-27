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
    "$SHELLSPEC_PRINTF" '%s\n' "$@" > "$file"
    set -- create "$file"
  fi
  relpath=${2#"$SHELLSPEC_CWD"}
  if [ "$relpath" = "$2" ]; then
    set -- "$1" "${SHELLSPEC_CWD%/}/$2"
  fi
  "$SHELLSPEC_PRINTF" '%8s   %s\n' "$1" "$2"
}

ignore_file() {
  [ "${2:-}" ] && echo "$2"
  echo "${1:-}.shellspec-local"
  echo "${1:-}.shellspec-quick.log"
  echo "${1:-}$SHELLSPEC_REPORTDIR/"
  echo "${1:-}$SHELLSPEC_COVERAGEDIR/"
}

${__SOURCED__:+return}

default_options() {
  echo "--require spec_helper"
  if [ ! "$SHELLSPEC_HELPERDIR" = "spec" ]; then
    echo "--helperdir $SHELLSPEC_HELPERDIR"
  fi
}

__ main __

generate ".shellspec" <<DATA
$(default_options)

## Default kcov (coverage) options
# --kcov-options "--include-path=. --path-strip-level=1"
# --kcov-options "--include-pattern=.sh"
# --kcov-options "--exclude-pattern=/.shellspec,/spec/,/coverage/,/report/"

## Example: Include script "myprog" with no extension
# --kcov-options "--include-pattern=.sh,myprog"

## Example: Only specified files/directories
# --kcov-options "--include-pattern=myprog,/lib/"
DATA

generate "$SHELLSPEC_HELPERDIR/spec_helper.sh" <<DATA
#shellcheck shell=sh

# set -eu

# shellspec_spec_helper_configure() {
#   shellspec_import 'support/custom_matcher'
# }
DATA

generate "spec/${SHELLSPEC_PROJECT_NAME}_spec.sh" <<'DATA'
Describe "Example specfile"
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
