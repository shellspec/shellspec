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
  [ "$relpath" = "$2" ] && set -- "$1" "${SHELLSPEC_CWD%/}/$2"
  "$SHELLSPEC_PRINTF" '%8s   %s\n' "$1" "$2"
}

spec() {
  eval "$1=\$3 $2=\$(cat)"
}

ignore_file() {
  [ "${2:-}" ] && echo "$2"
  echo "${1:-}.shellspec-local"
  echo "${1:-}.shellspec-quick.log"
  echo "${1:-}$SHELLSPEC_REPORTDIR/"
  echo "${1:-}$SHELLSPEC_COVERAGEDIR/"
}

default_options() {
  echo "--require spec_helper"
  if [ ! "$SHELLSPEC_HELPERDIR" = "spec" ]; then
    echo "--helperdir $SHELLSPEC_HELPERDIR"
  fi
}

${__SOURCED__:+return}

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
# shellcheck shell=sh

# Defining variables and functions here will affect all specfiles.
# Change shell options inside a function may cause different behavior,
# so it is better to set them here.
# set -eu

# This callback function will be invoked only once before loading specfiles.
spec_helper_precheck() {
  # Available functions: info, warn, error, abort, setenv, unsetenv
  # Available variables: VERSION, SHELL_TYPE, SHELL_VERSION
  : minimum_version "${SHELLSPEC_VERSION%%[+-]*}"
}

# This callback function will be invoked after a specfile has been loaded.
spec_helper_loaded() {
  :
}

# This callback function will be invoked after core modules has been loaded.
spec_helper_configure() {
  # Available functions: import, before_each, after_each, before_all, after_all
  : import 'support/custom_matcher'
}
DATA

specfile='' example=''
spec specfile example "spec/${SHELLSPEC_PROJECT_NAME}_spec.sh" <<'DATA'
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
    spec) generate "$specfile" "$example" ;;
    git ) generate ".gitignore" "$(ignore_file "/")" ;;
    hg  ) generate ".hgignore" "$(ignore_file "^" "syntax: regexp")" ;;
    svn ) generate ".svnignore" "$(ignore_file "/")" ;;
  esac
done
