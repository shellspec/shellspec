#shellcheck shell=sh disable=SC2016

% GENBIN: "$SHELLSPEC_TMPBASE/gen-bin"
% HELPERDIR: "$SHELLSPEC_TMPBASE/gen-bin/spec"

Describe "run shellspec-gen-bin.sh"
  # shellcheck disable=SC2034
  __main__() {
    SHELLSPEC_HELPERDIR="$HELPERDIR"
    SHELLSPEC_COLOR=''
    SHELLSPEC_SUPPORT_BINDIR="$HELPERDIR/support/bin"
  }
  Intercept main
  Path dummy-bin="$HELPERDIR/support/bin/@dummy"

  Context "when spec directory exists"
    Skip if "tmp directory is not executable" noexec_tmpdir

    setup() { @mkdir -p "$HELPERDIR"; }
    Before setup

    cleanup() { @rm -rf "$GENBIN"; }
    After cleanup

    mkdir() { @mkdir "$@"; }
    chmod() { @chmod "$@"; }

    It 'generates support bin'
      When run source ./libexec/shellspec-gen-bin.sh "@dummy"
      The output should start with "Generate @dummy"
      The file dummy-bin should be executable
    End
  End

  Context "when spec directory not exists"
    It 'raises error'
      When run source ./libexec/shellspec-gen-bin.sh "@dummy"
      The error should eq "shellspec helper directory not found: $HELPERDIR"
      The file dummy-bin should not exist
      The status should be failure
    End
  End

  Context "when spec support bin already exists"
    setup() {
      @mkdir -p "$HELPERDIR/support/bin"
      @touch "$HELPERDIR/support/bin/@dummy"
    }
    Before setup
    mkdir() { @mkdir "$@"; }

    It 'skips generate support bin'
      When run source ./libexec/shellspec-gen-bin.sh "@dummy"
      The error should start with "Skip, @dummy already exist"
      The file dummy-bin should exist
    End
  End
End
