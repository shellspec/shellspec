# How to test

## contrib/all.sh

Use `contrib/all.sh` to test on all installed shells.

Usage: `contrib/all.sh [COMMNAD (shellspec and etc)]`

## contrib/test_in_docker.sh

Use `contrib/test_in_docker.sh` to test on supported shells (Requires docker).

Usage: `contrib/test_in_docker.sh <DOCKERFILES...> [-- COMMAND]`

Dockerfile is in `dockerfiles` directory
(The filename begin with `.` is not a supported shell).

## contrib/check.sh

Use `contrib/check.sh` to check syntax whole project (Requires docker).

Usage: `contrib/check.sh`

## contrib/installr_test.sh

`contrib/installr_test.sh` is useful for creating a test environmen for the
installer. (Requires docker).

Usage: `contrib/installr_test.sh`
