#!/bin/sh

set -eu

: "${SH:=sh}"

$SH shellspec --banner
$SH shellspec --no-banner --skip-message queit -j 3
$SH shellspec --no-banner --skip-message queit $($SH shellspec --list-specfiles | head -n 5)
$SH shellspec --no-banner --skip-message queit $($SH shellspec --list-examples | head -n 5)
$SH shellspec --no-banner --skip-message queit spec/general_spec.sh:40:60:80:100
$SH shellspec --syntax-check
$SH shellspec --count
$SH shellspec --task
$SH shellspec --task hello:shellspec
