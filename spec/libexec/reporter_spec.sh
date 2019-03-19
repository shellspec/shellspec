#shellcheck shell=sh

Describe "libexec/reporter.sh"
  # shellcheck source=lib/libexec/reporter.sh
  . "$SHELLSPEC_LIB/libexec/reporter.sh"

  readonly file="$SHELLSPEC_SPECDIR/fixture/read_log.txt"

  Describe "wait_for_log_exists()"
    Before 'unixtime=0'
    unixtime() {
      unixtime=$((${unixtime:-0} + 1))
      eval "$1=$unixtime"
    }

    Example "return error if file missing"
      When call wait_for_log_exists "$file.not-exits" 10
      The variable unixtime should equal 11
      The status should be failure
    End

    Example "return success if file exits"
      When call wait_for_log_exists "$file" 10
      The status should be success
    End
  End

  Describe "read_log()"
    Example "do not read anything if file missing"
      When call read_log prefix "$file.not-exits"
      The variable prefix_name1 should be undefined
      The variable prefix_name2 should be undefined
      The status should be success
    End

    Example "read log data if file exists"
      When call read_log prefix "$file"
      The variable prefix_name1 should equal value1
      The variable prefix_name2 should equal value2
      The status should be success
    End
  End
End
