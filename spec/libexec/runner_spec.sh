#shellcheck shell=sh

Describe "libexec/runner.sh"
  # shellcheck source=lib/libexec/runner.sh
  . "$SHELLSPEC_LIB/libexec/runner.sh"

  Describe "mktempdir()"
    example() {
      dir="$SHELLSPEC_TMPBASE/$$.mktempdir_test"
      mktempdir "$dir"
      ls -dl "$dir"
      [ -d "$dir" ] && [ -w "$dir" ]
    }

    Example "make tempdir"
      When call example
      The first word of stdout should start with 'drwx------'
      The status should be success
    End
  End

  Describe "rmtempdir()"
    example() {
      dir="$SHELLSPEC_TMPBASE/$$.rmtempdir_test"
      mktempdir "$dir"
      rmtempdir "$dir"
      ! [ -e "$dir" ]
    }

    Example "delete tempdir"
      When call example
      The status should be success
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
