#!/bin/sh
#shellcheck disable=SC2002,SC2126

# Part of 21.intercept_spec.sh

# This is magic. "test" is a `test [expression]` well known as a shell command.
# Normally test without [expression] returns false. It means that __() { :; }
# function is defined if this script runs directly.
#
# shellspec overrides the test command and returns true *once*. It means that
# __() function defined internally by shellspec is called.
#
# In other words. If not in test mode, __ is just a comment. If test mode, __
# is a interception point.
test || __() { :; }

# Interception point. Syntax: `__ [point name] __`
__ begin __

# /proc/cpuinfo depends on the CPU owned by the user.
# It is difficult to test without stubs.
cat /proc/cpuinfo | grep processor | wc -l
