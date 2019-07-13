#shellcheck shell=sh disable=SC2016

Describe "core/evaluation.sh"
  Before 'VAR=123'

  Describe 'call evaluation'
    It 'outputs to stdout and stderr'
      evaluation() { echo ok; echo err >&2; return 0; }
      When call evaluation
      The output should equal 'ok'
      The error should equal 'err'
      The status should equal 0
    End

    It 'can able to change variable.'
      evaluation() { VAR=456; }
      When call evaluation
      The value "$VAR" should equal 456
    End

    It 'not restore mocked function after evaluation'
      echo_foo() { shellspec_puts 'foo'; }
      mock_foo() { echo_foo() { shellspec_puts 'FOO'; }; }
      When call mock_foo
      The result of 'echo_foo()' should equal 'FOO'
    End

    It 'calls shellspec_evaluation_cleanup() after evaluation'
      shellspec_around_invoke() {
        shellspec_evaluation_cleanup() { echo "cleanup: $1"; }
        "$@"
      }
      evaluation() { return 123; }
      When invoke shellspec_evaluation_call evaluation
      The stdout should equal 'cleanup: 123'
    End

    It 'accepts evaluatable string'
      When call 'echo "$@"' 1 2 3
      The stdout should equal '1 2 3'
    End

    It 'ensures errno 0 before evaluating function'
      relay_errno() { return ${?}; }
      When call relay_errno
      The status should equal 0
    End

    It 'reads data from stdin'
      Data "data"
      When call cat
      The stdout should equal 'data'
    End
  End

  Describe 'run evaluation'
    cat() { echo "fake cat"; return 1; }

    It 'calls external command'
      When run cat /dev/null
      The status should equal 0
    End

    It 'calls shellspec_evaluation_cleanup() after evaluation'
      shellspec_around_invoke() {
        shellspec_evaluation_cleanup() { echo "cleanup: $1"; }
        "$@"
      }
      When invoke shellspec_evaluation_run false
      The first word of stdout should equal 'cleanup:'
      The second word of stdout should be failure
    End

    It 'reads data from stdin'
      Data "data"
      When run cat
      The stdout should equal 'data'
    End
  End

  Describe 'invoke evaluation'
    It 'called then retrives stdout and stderr'
      evaluation() { echo ok; echo err >&2; return 0; }
      When invoke evaluation
      The stdout should equal 'ok'
      The stderr should equal 'err'
      The status should equal 0
    End

    It 'can not able to change variable.'
      evaluation() { VAR=456; }
      When invoke evaluation
      The value "$VAR" should equal 123
    End

    It 'restore mocked function after evaluation'
      echo_foo() { shellspec_puts 'foo'; }
      mock_foo() { echo_foo() { shellspec_puts 'FOO'; }; }
      When invoke mock_foo
      The result of 'echo_foo()' should equal 'foo'
    End

    It 'prevents exit'
      do_exit() { exit "$1"; }
      When invoke do_exit 12
      The status should equal 12
    End

    It 'calls shellspec_evaluation_cleanup() after evaluation'
      shellspec_around_invoke() {
        shellspec_evaluation_cleanup() { echo "cleanup: $1"; }
        "$@"
      }
      evaluation() { return 123; }
      When invoke shellspec_evaluation_invoke evaluation
      The stdout should equal 'cleanup: 123'
    End

    It 'accepts evaluatable string'
      When invoke 'echo "$@"' 1 2 3
      The stdout should equal '1 2 3'
    End

    It 'ensures errno 0 before calling external command'
      shellspec_around_invoke() { "$@"; }
      relay_errno() { return ${?}; }
      When invoke relay_errno
      The status should equal 0
    End

    It 'reads data from stdin'
      Data "data"
      When invoke cat
      The stdout should equal 'data'
    End
  End

  Describe 'shellspec_evaluation_cleanup()'
    It 'does not outputs anything and returns success'
      evaluation() { return 0; }
      When call evaluation
      The switch UNHANDLED_STATUS should satisfy switch_off
      The switch UNHANDLED_STDOUT should satisfy switch_off
      The switch UNHANDLED_STDERR should satisfy switch_off
      The stdout should equal ''
      The stderr should equal ''
      The status should equal 0
    End

    It 'outputs to stdout and returns success'
      evaluation() { echo ok; return 0; }
      When call evaluation
      The switch UNHANDLED_STATUS should satisfy switch_off
      The switch UNHANDLED_STDOUT should satisfy switch_on
      The switch UNHANDLED_STDERR should satisfy switch_off
      The stdout should equal ok
      The stderr should equal ''
      The status should equal 0
    End

    It 'outputs to stderr and returns success'
      evaluation() { echo err >&2; return 0; }
      When call evaluation
      The switch UNHANDLED_STATUS should satisfy switch_off
      The switch UNHANDLED_STDOUT should satisfy switch_off
      The switch UNHANDLED_STDERR should satisfy switch_on
      The stdout should equal ''
      The stderr should equal 'err'
      The status should equal 0
    End

    It 'outputs to stdout and stderr and returns success'
      evaluation() { echo ok; echo err >&2; return 0; }
      When call evaluation
      The switch UNHANDLED_STATUS should satisfy switch_off
      The switch UNHANDLED_STDOUT should satisfy switch_on
      The switch UNHANDLED_STDERR should satisfy switch_on
      The stdout should equal 'ok'
      The stderr should equal 'err'
      The status should equal 0
    End

    It 'does not output anything and returns error'
      evaluation() { return 123; }
      When call evaluation
      The switch UNHANDLED_STATUS should satisfy switch_on
      The switch UNHANDLED_STDOUT should satisfy switch_off
      The switch UNHANDLED_STDERR should satisfy switch_off
      The stdout should equal ''
      The stderr should equal ''
      The status should equal 123
    End

    It 'outputs to stdout and returns error'
      evaluation() { echo ok; return 123; }
      When call evaluation
      The switch UNHANDLED_STATUS should satisfy switch_on
      The switch UNHANDLED_STDOUT should satisfy switch_on
      The switch UNHANDLED_STDERR should satisfy switch_off
      The stdout should equal 'ok'
      The stderr should equal ''
      The status should equal 123
    End

    It 'outputs to stderr and returns error'
      evaluation() { echo err >&2; return 123; }
      When call evaluation
      The switch UNHANDLED_STATUS should satisfy switch_on
      The switch UNHANDLED_STDOUT should satisfy switch_off
      The switch UNHANDLED_STDERR should satisfy switch_on
      The stdout should equal ''
      The stderr should equal 'err'
      The status should equal 123
    End

    It 'outputs to stdout and stderr and returns error'
      evaluation() { echo ok; echo err >&2; return 123; }
      When call evaluation
      The switch UNHANDLED_STATUS should satisfy switch_on
      The switch UNHANDLED_STDOUT should satisfy switch_on
      The switch UNHANDLED_STDERR should satisfy switch_on
      The stdout should equal 'ok'
      The stderr should equal 'err'
      The status should equal 123
    End
  End
End
