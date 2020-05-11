#shellcheck shell=bash
set -o functrace
trap 'echo "kcov@${BASH_SOURCE:-}@${LINENO}@" >&$KCOV_BASH_XTRACEFD' DEBUG
