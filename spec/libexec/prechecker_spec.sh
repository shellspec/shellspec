#shellcheck shell=sh

Describe "libexec/prechecker.sh"
  Include "$SHELLSPEC_LIB/libexec/prechecker.sh"

  Describe "error()"
    _error() { error "$@" 2>&1 >/dev/null; }

    It 'outputs to stderr'
      When call _error "foo" "bar"
      The output should eq "foo bar"
    End
  End

  Describe "warn()"
    _warn() { warn "$@" 3>&1 >/dev/null; }

    It 'outputs to fd3'
      When call _warn "foo" "bar"
      The output should eq "foo bar"
    End
  End

  Describe "info()"
    _info() { info "$@" 4>&1 >/dev/null; }

    It 'outputs to fd4'
      When call _info "foo" "bar"
      The output should eq "foo bar"
    End
  End

  Describe "abort()"
    It 'exits with an error message'
      When run abort "foo" "bar"
      The error should eq "foo bar"
      The status should eq 1
    End

    It 'exits with an exit status'
      When run abort 2
      The error should eq "Aborted (exit status: 2)"
      The status should eq 2
    End

    It 'exits with an exit status and error message'
      When run abort 2 "foo" "bar"
      The error should eq "foo bar"
      The status should eq 2
    End
  End

  Describe "minimum_version()"
    Context "when the minimum version is not specified"
      It 'raises error'
        When call minimum_version
        The status should be failure
        The stderr should eq "minimum_version: The minimum version is not specified"
      End
    End

    Context "when an invalid version is specified"
      Parameters
        0.10a.0
        0.1.2@a
        0.1
        0.1.
        0.1.2.
        0..2
        0.1.2.3
      End

      It 'raises error'
        When call minimum_version "$1"
        The status should be failure
        The stderr should eq "minimum_version: Invalid version format (major.minor.patch[-pre][+build]): $1"
      End
    End

    Context "when the minimum version is not met"
      Before "VERSION=0.27.0"
      It 'raises error'
        When call minimum_version "0.28.0-pre"
        The status should be failure
        The stderr should eq "ShellSpec version 0.28.0-pre or higher is required"
      End
    End

    Parameters
      # current         minimum
      0.28.0            0.28.0        success blank
      0.28.0            0.28.0-patch  success blank
      0.28.0            0.28.0+build  failure present
      0.28.0+build      0.28.0+build  success blank
      0.28.0            0.28.1        failure present
      1.0.0             0.28.0        success blank
      0.28.0-dev        0.28.0        failure present
      0.28.0-dev+patch  0.28.0        failure present
      0.28.0+patch      0.28.0        success blank
      0.28.0+patch-foo  0.28.0        success blank
    End

    It 'checks shellspec version'
      BeforeCall "VERSION=$1"
      When call minimum_version "$2"
      The status should be "$3"
      The stderr should be "$4"
    End
  End
End
