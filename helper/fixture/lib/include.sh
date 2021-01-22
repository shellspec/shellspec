#!/bin/sh

foo() {
  echo foo
}

eval "get_sourced() { echo '$__SOURCED__'; }"

${__SOURCED__:+false} : || return 0

echo "this will not be executed" >&2
exit 1
