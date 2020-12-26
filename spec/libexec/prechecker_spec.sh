#shellcheck shell=sh

Describe "libexec/prechecker.sh"
  Include "$SHELLSPEC_LIB/libexec/prechecker.sh"

  Describe "error()"
    _error() { { error "$@" >/dev/null; } 2>&1; }

    It 'outputs to stderr'
      When call _error "foo" "bar"
      The output should eq "[error] foo bar"
    End
  End

  Describe "warn()"
    _warn() { warn "$@" 3>&1 >/dev/null; }

    It 'outputs to fd3'
      When call _warn "foo" "bar"
      The output should eq "[warn] foo bar"
    End
  End

  Describe "info()"
    _info() { info "$@" 4>&1 >/dev/null; }

    It 'outputs to fd4'
      When call _info "foo" "bar"
      The output should eq "[info] foo bar"
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
      When call minimum_version "0.27.0"
      The status should be success
    End

    It 'raises error when the minimum version is not specified'
      When call minimum_version
      The status should be failure
      The stderr should eq "[error] minimum_version: The minimum version is not specified"
    End

    It 'raises error when an invalid version is specified'
      When call minimum_version "0.10a.0"
      The status should be failure
      The stderr should eq "[error] minimum_version: Invalid version format (major.minor.patch[-pre][+build]): 0.10a.0"
    End

    It 'raises error when the minimum version is not met'
      When call minimum_version "0.28.0-pre"
      The status should be failure
      The stderr should eq "[error] ShellSpec version 0.28.0-pre or higher is required"
    End
  End
End
