#shellcheck shell=sh disable=SC2034

ARG1=${1:-} ARG2=${2:-} ARG3=${3:-}
[ ${1+x} ] || unset ARG1
[ ${2+x} ] || unset ARG2
[ ${3+x} ] || unset ARG3
set -- a b c
INCLUDED=1
