#!/bin/sh

# Measure metrics for shell scripts

# This script is for development purposes.
# It provide as is, do not any support.
# It may change without notice.

set -eu

sources() {
  echo shellspec
  echo install.sh
  find lib libexec helper -name '*.sh'
}

shellmetrics $(sources)
