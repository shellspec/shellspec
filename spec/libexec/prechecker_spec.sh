# shellcheck shell=sh disable=SC2016,SC2286,SC2287,SC2288

Describe "libexec/prechecker.sh"
  Include "$SHELLSPEC_LIB/libexec/prechecker.sh"

  Describe "error()"
    It 'outputs to stderr'
      When call error "foo" "bar"
      The error should eq "[error] foo bar"
    End
  End

  Describe "warn()"
    UseFD 3
    It 'outputs to fd3'
      When call warn "foo" "bar"
      The fd 3 should eq "[warn] foo bar"
    End
  End

  Describe "info()"
    UseFD 4
    It 'outputs to fd4'
      When call info "foo" "bar"
      The fd 4 should eq "[info] foo bar"
    End
  End

  Describe "abort()"
    It 'exits with an error message'
      When run abort "foo" "bar"
      The error should eq "[error] foo bar"
      The status should eq 1
    End

    It 'exits with an exit status'
      When run abort 2
      The error should eq "[error] Aborted (exit status: 2)"
      The status should eq 2
    End

    It 'exits with an exit status and error message'
      When run abort 2 "foo" "bar"
      The error should eq "[error] foo bar"
      The status should eq 2
    End
  End

  Describe "minimum_version()"
    Before "VERSION=0.27.0"

    It 'checks minimum version'
      When run minimum_version "0.27.0"
      The status should be success
    End

    It 'raises error when the minimum version is not specified'
      When run minimum_version
      The status should be failure
      The stderr should eq "[error] minimum_version: The minimum version is not specified"
    End

    It 'raises error when an invalid version is specified'
      When run minimum_version "0.10a.0"
      The status should be failure
      The stderr should eq "[error] minimum_version: Invalid version format (major.minor.patch[-pre][+build]): 0.10a.0"
    End

    It 'raises error when the minimum version is not met'
      When run minimum_version "0.28.0-pre"
      The status should be failure
      The stderr should eq "[error] ShellSpec version 0.28.0-pre or higher is required"
    End
  End

  Describe "setenv()"
    _setenv() { { setenv "$@" >/dev/null; } 9>&1; }

    It 'outputs the export statement to fd9'
      When run _setenv A="123 '\" 456=789" B=abc
      The line 1 should eq "export A='123 '\''\" 456=789'"
      The line 2 should eq "export B='abc'"
    End

    It 'outputs the export statement to fd9 when not specified the value'
      When run _setenv A=
      The output should eq "export A=''"
    End

    It 'raises error when the value for environment variable is not specified'
      When run _setenv A
      The status should be failure
      The error should eq "[error] setenv: No value for environment variable: A"
    End

    It 'raises error when the environment variable name is invalid'
      When run _setenv "-@"
      The status should be failure
      The error should eq "[error] setenv: Invalid environment variable name: -@"
    End
  End

  Describe "unsetenv()"
    _unsetenv() { { unsetenv "$@" >/dev/null; } 9>&1; }

    It 'outputs the unset statement to fd9'
      When run _unsetenv A B
      The line 1 should eq "unset A ||:"
      The line 2 should eq "unset B ||:"
    End

    It 'raises error when the environment variable name is invalid'
      When run _unsetenv "-@"
      The status should be failure
      The error should eq "[error] unsetenv: Invalid environment variable name: -@"
    End
  End
End
