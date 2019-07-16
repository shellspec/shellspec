#!/bin/sh

#shellcheck disable=SC2034
readonly value=123

foo() {
  echo foo
}

eval "get_sourced() { echo '$__SOURCED__'; }"

${__SOURCED__:+return}

echo "this will not be executed"
