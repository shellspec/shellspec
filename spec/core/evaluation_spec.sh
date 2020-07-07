#shellcheck shell=sh disable=SC2016

% BIN: "$SHELLSPEC_SPECDIR/fixture/bin"
% FIXTURE: "$SHELLSPEC_SPECDIR/fixture"
% TMPBASE: "$SHELLSPEC_TMPBASE"

Describe "core/evaluation.sh"
  Include "$SHELLSPEC_LIB/core/evaluation.sh"
  Before 'VAR=123'

  Describe 'shellspec_evaluation_from_tty()'
    prepare() { echo "tty data" > "$SHELLSPEC_STDIN_DEV"; }
    BeforeRun 'SHELLSPEC_STDIN_DEV="$TMPBASE/tty"' prepare
    It "reads from tty"
      When run shellspec_evaluation_from_tty cat
      The stdout should equal "tty data"
    End
  End

  Describe 'shellspec_evaluation_from_stdin()'
    prepare() { echo "stdin data" > "$SHELLSPEC_STDIN_FILE"; }
    BeforeRun 'SHELLSPEC_STDIN_FILE="$TMPBASE/stdin"' prepare
    It "reads from tty"
      When run shellspec_evaluation_from_stdin cat
      The stdout should equal 'stdin data'
    End
  End

  Describe 'shellspec_evaluation_to_null()'
    It "writes to /dev/null"
      When run shellspec_evaluation_to_null echo "null data"
      The stdout should be blank
    End
  End

  Describe 'shellspec_evaluation_to_stdout()'
    BeforeRun 'SHELLSPEC_STDOUT_FILE="$TMPBASE/stdout"'
    AfterRun 'cat "$SHELLSPEC_STDOUT_FILE"'
    It "writes to stdout file"
      When run shellspec_evaluation_to_stdout echo "stdout data"
      The stdout should equal 'stdout data'
    End
  End

  Describe 'shellspec_evaluation_to_stderr()'
    BeforeRun 'SHELLSPEC_STDERR_FILE="$TMPBASE/stderr"'
    AfterRun 'cat "$SHELLSPEC_STDERR_FILE" >&2'
    stderr_data() { echo "stderr data"; }
    It "writes to stderr file"
      When run shellspec_evaluation_to_stderr stderr_data
      The stdout should equal 'stderr data'
    End
  End

  Describe 'shellspec_evaluation_to_xtrace()'
    BeforeRun 'SHELLSPEC_XTRACEFD=1' 'SHELLSPEC_XTRACE_FILE="$TMPBASE/trace"'
    AfterRun 'cat "$SHELLSPEC_XTRACE_FILE"'
    It "writes to trace file"
      When run shellspec_evaluation_to_xtrace echo "trace data"
      The stdout should include 'trace data'
    End
  End

  Describe 'shellspec_evaluation_execute()'
    Skip if "The posh cannot redefine running function" [ "${POSH_VERSION:-}" ]

    mock() {
      shellspec_evaluation_from_tty() { echo "from tty"; "$@"; }
      shellspec_evaluation_from_stdin() { echo "from stdin"; "$@"; }
      shellspec_evaluation_to_null() { echo "to null"; "$@"; }
      shellspec_evaluation_to_stdout() { echo "to stdout"; "$@"; }
      shellspec_evaluation_to_stderr() { echo "to stderr"; "$@"; }
      shellspec_evaluation_to_xtrace() { echo "to xtrace"; "$@"; }
    }
    BeforeRun mock

    Context "when test mode without data"
      evaluation_execute() {
        SHELLSPEC_XTRACE="" SHELLSPEC_XTRACE_ONLY="" SHELLSPEC_DATA=""
        shellspec_evaluation_execute "$@"
      }
      It "writes to trace file"
        When run evaluation_execute :
        The stdout should include 'from tty'
        The stdout should include 'to stdout'
        The stdout should include 'to stderr'
      End
    End

    Context "when test mode with data"
      evaluation_execute() {
        SHELLSPEC_XTRACE="" SHELLSPEC_XTRACE_ONLY="" SHELLSPEC_DATA=1
        shellspec_evaluation_execute "$@"
      }
      It "writes to trace file"
        When run evaluation_execute :
        The stdout should include 'from stdin'
        The stdout should include 'to stdout'
        The stdout should include 'to stderr'
      End
    End

    Context "when trace mode without data"
      evaluation_execute() {
        SHELLSPEC_XTRACE=1 SHELLSPEC_XTRACE_ONLY="" SHELLSPEC_DATA=""
        shellspec_evaluation_execute "$@"
      }
      It "writes to trace file"
        When run evaluation_execute :
        The stdout should include 'from tty'
        The stdout should include 'to stdout'
        The stdout should include 'to stderr'
      End
    End

    Context "when trace-only mode without data"
      evaluation_execute() {
        # shellcheck disable=SC2034
        SHELLSPEC_XTRACE=1 SHELLSPEC_XTRACE_ONLY=1 SHELLSPEC_DATA=""
        shellspec_evaluation_execute "$@"
      }
      It "writes to trace file"
        When run evaluation_execute :
        The stdout should include 'from tty'
        The stdout should include 'to null'
      End
    End
  End

  Describe 'shellspec_invoke_data()'
    shellspec_data() {
      echo "${1:-test1}"
      echo "${2:-test2}"
    }

    BeforeRun SHELLSPEC_DATA=1

    It 'generates data'
      File in-file="$SHELLSPEC_STDIN_FILE"
      When run shellspec_invoke_data
      The line 1 of contents of file in-file should equal 'test1'
      The line 2 of contents of file in-file should equal 'test2'
    End

    It 'generates data with parameters'
      File in-file="$SHELLSPEC_STDIN_FILE"
      When run shellspec_invoke_data testA testB
      The line 1 of contents of file in-file should equal 'testA'
      The line 2 of contents of file in-file should equal 'testB'
    End
  End

  Describe 'call evaluation'
    Before shellspec_coverage_start
    shellspec_coverage_stop() { :; } # Do not stop coverage

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

    It 'catches error when even enable errexit within function'
      evaluation() { set -e; return 123; }
      When call evaluation
      The status should eq 123
    End

    It 'reads data from stdin'
      Data "data"
      When call cat
      The stdout should equal 'data'
    End

    It 'calls external command'
      cat() { echo "should not be executed"; return 1; }
      When run command cat /dev/null
      The status should equal 0
    End

    It 'can not aborts with set -e'
      Skip if 'errexit handling broken' [ "$SHELLSPEC_DEFECT_ERREXIT" ]
      evaluation() { set -e; echo 1; false; echo 2; }
      When call evaluation
      The line 1 of stdout should equal "1"
      The line 2 of stdout should equal "2"
      The status should equal 0
    End

    It "ensures no pipe and term"
      evaluation() {
        [ -p /dev/stdin ] && echo "pipe" || echo "no pipe"
        [ -t 0 ] && echo "term" || echo "no term"
      }
      term() { exists_tty && echo "term" || echo "no term"; }

      When call evaluation
      The line 1 of stdout should equal 'no pipe'
      The line 2 of stdout should equal "$(term)"
    End
  End

  Describe 'shellspec_evaluation_call_function()'
    Context "when xtrace is on"
      call_function() {
        shellspec_coverage_start() { :; }
        shellspec_coverage_stop() { :; }
        SHELLSPEC_XTRACE=1
        SHELLSPEC_XTRACE_ON="echo xtrace on"
        SHELLSPEC_XTRACE_OFF="echo xtrace off; set"
        shellspec_evaluation_call_function "$@"
      }
      It "calls function with trace"
        When run call_function :
        The line 1 should eq "xtrace on"
        The line 2 should eq "xtrace off"
      End
    End
  End

  Describe 'run evaluation'
    Before shellspec_coverage_start
    shellspec_coverage_stop() { :; } # Do not stop coverage

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

    It 'catches error when even enable errexit within function'
      evaluation() { set -e; return 123; }
      When run evaluation
      The status should eq 123
    End

    It 'reads data from stdin'
      Data "data"
      When run command cat
      The stdout should equal 'data'
    End

    It "ensures no pipe and term"
      evaluation() {
        [ -p /dev/stdin ] && echo "pipe" || echo "no pipe"
        [ -t 0 ] && echo "term" || echo "no term"
      }
      term() { exists_tty && echo "term" || echo "no term"; }

      When run evaluation
      The line 1 of stdout should equal 'no pipe'
      The line 2 of stdout should equal "$(term)"
    End

    Describe 'abort test'
      Skip if 'shell flag handling broken' posh_shell_flag_bug
      evaluation() { set -e; echo line1; "$BIN/exit.sh" 12; echo line2; }

      Context "when errexit is on"
        Set errexit:on
        It 'aborts with set -e'
          When run evaluation
          The stdout should equal line1
          The status should equal 12
        End
      End

      Context "when errexit is off"
        Set errexit:off
        It 'aborts with set -e'
          When run evaluation
          The stdout should equal line1
          The status should equal 12
        End
      End
    End

    Describe 'run script evaluation'
      Describe 'shellspec_shebang_arguments()'
        Parameters
          "#!/bin/sh -u"            "-u"
          "#!/bin/sh   -u -u  "     "-u -u"
          "#!/bin/sh          "     ""
          "/bin/sh -u"              ""
          "#!/usr/bin/env bash"     ""
          "#!/bin/env bash"         ""
        End

        shebang_arguments() {
          echo "$1" | shellspec_shebang_arguments
        }

        It 'gets shebang arguments'
          When call shebang_arguments "$1"
          The stdout should equal "$2"
        End
      End

      It 'should be error if not exists file'
        When run script not-exists-file
        The stderr should be present
        The status should be failure
      End

      It 'should be error if not executable file'
        When run script "$FIXTURE/file"
        The stderr should be present
        The status should be failure
      End

      Describe 'shebang arguments'
        set_fake_shell() { export SHELLSPEC_SHELL="$SHELLSPEC_PRINTF '%s\n'"; }
        shellspec_shebang_arguments() { %= "-u -u -u -u"; }
        Before set_fake_shell

        Context 'Not support shebang multiple arguments'
          Before SHELLSPEC_SHEBANG_MULTIARG=''
          It 'treats as one argument'
            When run script "$BIN/echo"
            The stdout should include "-u -u -u -u"
          End
        End

        Context 'Support shebang multiple arguments'
          Before SHELLSPEC_SHEBANG_MULTIARG=1
          It 'treats as multiple arguments'
            When run script "$BIN/echo"
            The stdout should not include "-u -u -u -u"
          End
        End
      End
    End

    Describe 'shellspec_evaluation_run_script()'
      Context "when xtrace is on"
        # shellcheck disable=SC2034
        run_script() {
          SHELLSPEC_XTRACE=1
          SHELLSPEC_XTRACEFD_VAR="SH_XTRACEFD"
          SHELLSPEC_XTRACEFD=3
          PS4="@"
          shellspec_evaluation_run_script "$@"
        }
        It "runs script with trace"
          When run run_script "$BIN/trace"
          The line 1 should eq "SHELLSPEC_PS4: @"
          The line 2 should eq "SH_XTRACEFD: 3"
          Skip if "set -x broken" posh_shell_flag_bug
          The stderr should include "$(printf '\n@echo ')"
        End
      End
    End

    Describe 'run command evaluation'
      It 'runs external command'
        cat() { echo "should not be executed"; return 1; }
        When run command cat /dev/null
        The status should equal 0
      End

      It 'catches error of external command'
        When run command cat --unknown-option
        The status should be failure
        The stderr should be present
      End

      It 'returns 127 when external command not found'
        When run command no-such-a-command 'bad'
        The status should eq 127
        The stderr should be present
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

    Describe 'shellspec_evaluation_run_source()'
      Context "when xtrace is on"
        # shellcheck disable=SC2034
        run_source() {
          shellspec_coverage_start() { :; }
          shellspec_coverage_stop() { :; }
          SHELLSPEC_XTRACE=1
          SHELLSPEC_XTRACE_ON="echo xtrace on"
          SHELLSPEC_XTRACE_OFF="echo xtrace off; set"
          shellspec_evaluation_run_source "$@"
        }
        It "runs source with trace"
          When run run_source "$BIN/echo"
          The line 1 should eq "xtrace on"
          The line 3 should eq "xtrace off"
        End
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
