#shellcheck shell=sh

Describe "libexec/runner.sh"
  Include "$SHELLSPEC_LIB/libexec/runner.sh"

  Describe "mktempdir()"
    Before prepare
    prepare() { dir="$SHELLSPEC_TMPBASE/$$.mktempdir_test"; }
    entry() { ls -dl "$dir"; }

    It "makes tempdir"
      When call mktempdir "$dir"
      The status should be success
      The result of 'entry()' should start with 'drwx------'
    End
  End

  Describe "rmtempdir()"
    Before prepare
    prepare() {
      dir="$SHELLSPEC_TMPBASE/$$.rmtempdir_test"
      mktempdir "$dir"
      [ -d "$dir" ] && [ -w "$dir" ]
    }

    It "deletes tempdir"
      Path tempdir="$dir"
      When call rmtempdir "$dir"
      The status should be success
      The path tempdir should not be exist
    End
  End
End
