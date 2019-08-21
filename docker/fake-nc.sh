#!/bin/sh

for i in "$@"; do
  shift
  case $i in (-*) continue; esac
  set -- "$@" "$i"
done

mksock "$@"
