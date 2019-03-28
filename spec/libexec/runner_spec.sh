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

  Describe "time_result()"
    It "parses real 0.01 as time result"
      When call time_result "real   0.01"
      The stdout should equal "real   0.01"
      The status should be success
    End

    It "parses user 0.01 as time result"
      When call time_result "user   0.01"
      The stdout should equal "user   0.01"
      The status should be success
    End

    It "parses sys 0.01 as time result"
      When call time_result "sys   0.01"
      The stdout should equal "sys   0.01"
      The status should be success
    End

    It "does not parse real 0.01a as time result"
      When call time_result "real   0.01a"
      The status should be failure
    End
  End
End
