#!/bin/sh

set -eu

: "${SH:=sh}"

$SH shellspec --banner
$SH shellspec --no-banner -j 3
$SH shellspec --no-banner $($SH shellspec --list-specfiles | head -n 5)
$SH shellspec --no-banner $($SH shellspec --list-examples | head -n 5)
$SH shellspec --no-banner spec/general_spec.sh:40:60:80:100
$SH shellspec --syntax-check
$SH shellspec --count
$SH shellspec --task
$SH shellspec --task hello:shellspec
