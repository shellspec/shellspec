#!/bin/sh

foo() {
  echo foo
}

eval "get_sourced() { echo '$__SOURCED__'; }"

eval ${__SOURCED__:+return 0}

echo "this will not be executed"
