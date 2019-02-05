#!/bin/bash

# Shell script beautify tool

# This script is for development purposes.
# It provide as is, do not any support.
# It may change without notice.

# Example of use
#   cat example.sh | contrib/pretty.sh

eval "__dummy__() {
  $(cat -)
}"
typeset -f __dummy__ | sed -E 's/( *)function /\1/; s/;$//'
