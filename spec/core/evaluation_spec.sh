#shellcheck shell=sh

Describe "core/evaluation.sh"
  Before 'VAR=123'

  output_stdout() { echo ok; ret; }
  output_stderr() { echo err >&2; ret; }
  output_both() { echo ok; echo err >&2; ret; }
  output_none() { ret; }
  change_variable() { VAR=$1; }
  do_exit() { exit "$1"; }
  ret() { return 0; }
  ret123() { return 123; }

  echo_foo() { echo 'foo'; }

  call() {
    shellspec_evaluation_cleanup() {
      echo "shellspec_evaluation_cleanup: $1"
    }
    "$@"
  }

  switch_on() { shellspec_if "$SHELLSPEC_SUBJECT"; }
  switch_off() { shellspec_unless "$SHELLSPEC_SUBJECT"; }

  Describe 'call evaluation'
    Example 'output stdout and stderr'
      When call output_both
      The output should equal 'ok'
      The error should equal 'err'
      The status should equal 0
    End

    Example 'can able to change variable.'
      When call change_variable 456
      The value "$VAR" should equal 456
    End

    Example 'not restore mock function after evaluation'
      mock_foo() { echo_foo() { echo 'FOO'; }; }
      When call mock_foo
      The function echo_foo should equal 'FOO'
    End

    Example 'call shellspec_evaluation_cleanup() after evaluation'
      When invoke call shellspec_evaluation_call ret123
      The stdout should equal 'shellspec_evaluation_cleanup: 123'
    End
  End

  Describe 'run evaluation'
    cat() { echo "fake cat"; return 1; }

    Example 'call external command'
      When run cat /dev/null
      The status should equal 0
    End

    Example 'call shellspec_evaluation_cleanup() after evaluation'
      When invoke call shellspec_evaluation_call ret123
      The stdout should equal 'shellspec_evaluation_cleanup: 123'
    End
  End

  Describe 'invoke evaluation'
    Example 'called then retrive stdout and stderr'
      When invoke output_both
      The stdout should equal 'ok'
      The stderr should equal 'err'
      The status should equal 0
    End

    Example 'can not able to change variable.'
      When invoke change_variable 456
      The variable VAR should equal 123
    End

    Example 'restore mock function after evaluation'
      mock_foo() { echo_foo() { echo 'FOO'; }; }
      When invoke mock_foo
      The function echo_foo should equal 'foo'
    End

    Example 'prevent exit.'
      shell_has_bug() {
        # I confirmed zsh 4.2.0. (there may be other things)
        (exit 123) &&:; [ $? -ne 123 ]
      }
      Skip if "can not get the exit status" shell_has_bug
      When invoke do_exit 12
      The status should equal 12
    End

    Example 'call shellspec_evaluation_cleanup() after evaluation'
      When invoke call shellspec_evaluation_invoke ret123
      The stdout should equal 'shellspec_evaluation_cleanup: 123'
    End
  End

  Describe 'shellspec_evaluation_cleanup()'
    Context 'calls a function that returns success'
      Example 'with do not output anything'
        When call output_none
        The value UNHANDLED_STATUS should satisfy switch_off
        The value UNHANDLED_STDOUT should satisfy switch_off
        The value UNHANDLED_STDERR should satisfy switch_off
        The stdout should equal ''
        The stderr should equal ''
        The status should equal 0
      End

      Example 'with output to stdout'
        When call output_stdout
        The value UNHANDLED_STATUS should satisfy switch_off
        The value UNHANDLED_STDOUT should satisfy switch_on
        The value UNHANDLED_STDERR should satisfy switch_off
        The stdout should equal ok
        The stderr should equal ''
        The status should equal 0
      End

      Example 'with output to stderr'
        When call output_stderr
        The value UNHANDLED_STATUS should satisfy switch_off
        The value UNHANDLED_STDOUT should satisfy switch_off
        The value UNHANDLED_STDERR should satisfy switch_on
        The stdout should equal ''
        The stderr should equal 'err'
        The status should equal 0
      End

      Example 'with output to stdout and stderr'
        When call output_both
        The value UNHANDLED_STATUS should satisfy switch_off
        The value UNHANDLED_STDOUT should satisfy switch_on
        The value UNHANDLED_STDERR should satisfy switch_on
        The stdout should equal 'ok'
        The stderr should equal 'err'
        The status should equal 0
      End
    End

    Context 'calls a function that returns error'
      ret() { return 123; }

      Example 'with do not output anything'
        When call output_none
        The value UNHANDLED_STATUS should satisfy switch_on
        The value UNHANDLED_STDOUT should satisfy switch_off
        The value UNHANDLED_STDERR should satisfy switch_off
        The stdout should equal ''
        The stderr should equal ''
        The status should equal 123
      End

      Example 'with output to stdout'
        When call output_stdout
        The value UNHANDLED_STATUS should satisfy switch_on
        The value UNHANDLED_STDOUT should satisfy switch_on
        The value UNHANDLED_STDERR should satisfy switch_off
        The stdout should equal 'ok'
        The stderr should equal ''
        The status should equal 123
      End

      Example 'with output to stderr'
        When call output_stderr
        The value UNHANDLED_STATUS should satisfy switch_on
        The value UNHANDLED_STDOUT should satisfy switch_off
        The value UNHANDLED_STDERR should satisfy switch_on
        The stdout should equal ''
        The stderr should equal 'err'
        The status should equal 123
      End

      Example 'with output to stdout and stderr'
        When call output_both
        The value UNHANDLED_STATUS should satisfy switch_on
        The value UNHANDLED_STDOUT should satisfy switch_on
        The value UNHANDLED_STDERR should satisfy switch_on
        The stdout should equal 'ok'
        The stderr should equal 'err'
        The status should equal 123
      End
    End
  End
End
