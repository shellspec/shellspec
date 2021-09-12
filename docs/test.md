# How to test

## contrib/all.sh

Use `contrib/all.sh` to test on all installed shells.

Usage: `contrib/all.sh [COMMAND (shellspec and etc)]`

## contrib/test_in_docker.sh

Use `contrib/test_in_docker.sh` to test on supported shells (requires Docker).

Usage: `contrib/test_in_docker.sh <DOCKERFILES...> [-- COMMAND]`

The Dockerfiles are in the `dockerfiles` directory (the files whose name begin
with `.` are for unsupported shells).

## contrib/check.sh

Use `contrib/check.sh` to check syntax on the whole project (requires docker).

Usage: `contrib/check.sh`

## contrib/installer_test.sh

`contrib/installer_test.sh` is useful for creating a test environment for the
installer (requires docker).

Usage: `contrib/installer_test.sh`
