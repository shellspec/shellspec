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
      shellspec_around_invoke() {
        shellspec_evaluation_cleanup() { echo "cleanup: $1"; }
        "$@"
      }
      evaluation() { return 123; }
      When invoke shellspec_evaluation_call evaluation
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
      echo_foo() { echo 'foo'; }
      mock_foo() {
        echo_foo() { echo 'FOO'; }
      }
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

  Describe 'execute evaluation'
    Specify 'The script runs without any problems'
      When run "$BIN/script.sh"
      The status should be success
    End

    It 'executes script'
      When execute "$BIN/script.sh"
      The status should be success
    End

    It 'calls shellspec_intercept'
      Intercept intercept

      # You can overrite here
      __intercept__() {
        date() { echo "now"; }
      }

      When execute "$BIN/script.sh" --command date
      The status should be success
      The stdout should equal "now"
    End

    It 'can pass arguments'
      When execute "$BIN/script.sh" --dump-params a b c
      The status should be success
      The stdout should equal "--dump-params a b c"
    End

    It 'catches exit code'
      When execute "$BIN/script.sh" --exit-with 123
      The status should eq 123
    End

    Specify '"test" return to the original behavior'
      When execute "$BIN/script.sh" --command test
      The status should be failure
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
