#shellcheck shell=sh disable=SC2016

% BIN: "$SHELLSPEC_SPECDIR/fixture/bin"

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
      echo_foo() { echo 'foo'; }
      mock_foo() {
        echo_foo() { echo 'FOO'; }
      }
      When call mock_foo
      The result of 'echo_foo()' should equal 'FOO'
    End

    It 'calls shellspec_evaluation_cleanup() after evaluation'
      mock() {
        shellspec_evaluation_cleanup() { echo "cleanup: $1"; }
      }
      evaluation() { return 123; }
      BeforeRun mock
      When run shellspec_evaluation_call evaluation
      The stdout should equal 'cleanup: 123'
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

    It 'calls external command'
      cat() { echo "fake cat"; return 1; }
      When call command cat /dev/null
      The status should equal 0
    End

    It 'can not aborts with set -e'
      evaluation() { set -e; echo 1; false; echo 2; }
      When call evaluation
      The stdout should equal "1${LF}2"
      The status should equal 0
    End
  End

  Describe 'run evaluation'
    It 'called then retrives stdout and stderr'
      evaluation() { echo ok; echo err >&2; return 0; }
      When run evaluation
      The stdout should equal 'ok'
      The stderr should equal 'err'
      The status should equal 0
    End

    It 'can not able to change variable.'
      evaluation() { VAR=456; }
      When run evaluation
      The value "$VAR" should equal 123
    End

    It 'restore mocked function after evaluation'
      echo_foo() { echo 'foo'; }
      mock_foo() {
        echo_foo() { echo 'FOO'; }
      }
      When run mock_foo
      The result of 'echo_foo()' should equal 'foo'
    End

    It 'prevents exit'
      do_exit() { exit "$1"; }
      When run do_exit 12
      The status should equal 12
    End

    It 'calls shellspec_evaluation_cleanup() after evaluation'
      mock() {
        shellspec_evaluation_cleanup() { echo "cleanup: $1"; }
      }
      BeforeRun mock
      When run shellspec_evaluation_run false
      The first word of stdout should equal 'cleanup:'
      The second word of stdout should be failure
    End

    It 'ensures errno 0 before evaluating function'
      relay_errno() { return ${?}; }
      When run relay_errno
      The status should equal 0
    End

    It 'reads data from stdin'
      Data "data"
      When run command cat
      The stdout should equal 'data'
    End

    Describe 'abort test'
      evaluation() { set -e; echo line1; "$BIN/exit.sh" 12; echo line2; }

      Context "when errexit is on"
        Set errexit:on
        It 'aborts with set -e'
          When run evaluation
          The stdout should equal line1
          The status should equal 12
          The value "$-" should include "e"
        End
      End

      Context "when errexit is off"
        Set errexit:off
        It 'aborts with set -e'
          When run evaluation
          The stdout should equal line1
          The status should equal 12
          The value "$-" should not include "e"
        End
      End
    End

    Describe 'run command evaluation'
      It 'runs external command'
        cat() { echo "fake cat"; return 1; }
        When run command cat /dev/null
        The status should equal 0
      End
    End

    Describe 'run source evaluation'
      It 'executes script'
        When run source "$BIN/script.sh"
        The status should be success
      End

      It 'calls shellspec_intercept'
        Intercept intercept

        # You can overrite here
        __intercept__() {
          iconv() { echo "overrided"; }
        }

        When run source "$BIN/script.sh" --command iconv -l
        The status should be success
        The stdout should equal "overrided"
      End

      It 'can pass arguments'
        When run source "$BIN/script.sh" --dump-params a b c
        The status should be success
        The stdout should equal "--dump-params a b c"
      End

      It 'catches exit code'
        When run source "$BIN/script.sh" --exit-with 123
        The status should eq 123
      End

      Specify '"test" return to the original behavior'
        When run source "$BIN/script.sh" --command test
        The status should be failure
      End
    End
  End

  Describe 'shellspec_interceptor()'
    foo() { echo foo; }
    foo2() { echo foo2; }
    bar() { printf '%s ' bar "$@"; }

    Context 'when interceptor exists'
      Before 'SHELLSPEC_INTERCEPTOR="|foo:foo|bar:bar|"'

      It 'calls interceptor'
        When call shellspec_interceptor foo __
        The output should eq "foo"
      End

      It 'calls interceptor with arguments'
        When call shellspec_interceptor bar 1 2 __
        The output should eq "bar 1 2 "
      End

      It 'does not call interceptor without last __'
        When call shellspec_interceptor foo
        The output should be blank
      End
    End

    Context 'when interceptor overrided'
      Before 'SHELLSPEC_INTERCEPTOR="|foo:foo|foo:foo2|"'

      It 'calls interceptor'
        When call shellspec_interceptor foo __
        The output should eq "foo2"
      End
    End

    Context 'when interceptor not exists'
      Before 'SHELLSPEC_INTERCEPTOR="|foo:foo|bar:bar|"'

      It 'does not call interceptor'
        When call shellspec_interceptor baz __
        The output should be blank
      End
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
