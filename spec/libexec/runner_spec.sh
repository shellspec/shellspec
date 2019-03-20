#shellcheck shell=sh

Describe "libexec/runner.sh"
  # shellcheck source=lib/libexec/runner.sh
  . "$SHELLSPEC_LIB/libexec/runner.sh"

  Describe "mktempdir()"
    readonly dir="$SHELLSPEC_TMPBASE/$$.mktempdir_test"

    entry() { ls -dl "$dir"; }
    check_perm() { [ -d "$dir" ] && [ -w "$dir" ]; }

    Example "make tempdir"
      When call mktempdir "$dir"
      The status should be success
      The output of 'entry()' should start with 'drwx------'
      The status of 'check_perm()' should be success
    End
  End

  Describe "rmtempdir()"
    readonly dir="$SHELLSPEC_TMPBASE/$$.rmtempdir_test"

    prepare() {
      mktempdir "$dir"
      [ -d "$dir" ] && [ -w "$dir" ]
    }
    Before prepare

    exists_tempdir() { [ -e "$dir" ]; }

    Example "delete tempdir"
      When call rmtempdir "$dir"
      The status should be success
      The status of 'exists_tempdir()' should be failure
    End
  End

  Describe "time_result()"
    Example "parse real 0.01 as time result"
      When call time_result "real   0.01"
      The stdout should equal "real   0.01"
      The status should be success
    End

    Example "parse user 0.01 as time result"
      When call time_result "user   0.01"
      The stdout should equal "user   0.01"
      The status should be success
    End

    Example "parse sys 0.01 as time result"
      When call time_result "sys   0.01"
      The stdout should equal "sys   0.01"
      The status should be success
    End

    Example "does not parse real 0.01a as time result"
      When call time_result "real   0.01a"
      The status should be failure
    End
  End
End
