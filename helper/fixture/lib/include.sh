#!/bin/sh

foo() {
  echo foo
}

eval "get_sourced() { echo '$__SOURCED__'; }"

${__SOURCED__:+return}

echo "this will not be executed"
