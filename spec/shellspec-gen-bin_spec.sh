#shellcheck shell=sh disable=SC2016

% GENBIN: "$SHELLSPEC_TMPBASE/gen-bin"

Describe "run shellspec-gen-bin.sh"
  __main__() {
    SHELLSPEC_SPECDIR="$GENBIN/spec"
    SHELLSPEC_SUPPORT_BIN="$SHELLSPEC_SPECDIR/support/bin"
  }
  Intercept main
  Path dummy-bin="$GENBIN/spec/support/bin/@dummy"

  Context "when spec directory exists"
    setup() { @mkdir -p "$GENBIN/spec"; }
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
      The output should eq "Not a shellspec directory"
      The file dummy-bin should not be exist
      The status should be failure
    End
  End

  Context "when spec support bin already exists"
    setup() {
      @mkdir -p "$GENBIN/spec/support/bin"
      @touch "$GENBIN/spec/support/bin/@dummy"
    }
    Before setup
    mkdir() { @mkdir "$@"; }

    It 'skips generate support bin'
      When run source ./libexec/shellspec-gen-bin.sh "@dummy"
      The output should start with "Skip, @dummy already exist"
      The file dummy-bin should be exist
    End
  End
End
