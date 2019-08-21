#!/bin/sh

export SUDO_GID=$(id -g user) SUDO_UID=$(id -u user)

"$@"
