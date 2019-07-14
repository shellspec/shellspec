#!/bin/sh

for i in "$@"; do
  case $i in
    -*) ;;
    *) set -- "$@" "$i" ;;
  esac
  shift
done

if [ $# -gt 0 ]; then
  mksock "$1"
fi
