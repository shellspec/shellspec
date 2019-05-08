#!/bin/sh

set -eu

: "${SH:=sh}"

$SH shellspec --banner
$SH shellspec --no-banner --skip-message quiet -j 3
$SH shellspec --no-banner --skip-message quiet $($SH shellspec --list specfiles | head -n 5)
$SH shellspec --no-banner --skip-message quiet $($SH shellspec --list examples:lineno | head -n 5)
$SH shellspec --no-banner --skip-message quiet spec/general_spec.sh:40:60:80:100
$SH shellspec --syntax-check
$SH shellspec --count
$SH shellspec --task
$SH shellspec --task hello:shellspec
