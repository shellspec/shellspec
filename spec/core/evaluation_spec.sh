#shellcheck shell=sh disable=SC2016

Describe "core/evaluation.sh"
  Before 'VAR=123'

  shellspec_around_invoke() {
    shellspec_evaluation_cleanup() { echo "cleanup: $1"; }
    "$@"
  }

  Describe 'call evaluation'
    Example 'output stdout and stderr'
      evaluation() { echo ok; echo err >&2; return 0; }
      When call evaluation
      The output should equal 'ok'
      The error should equal 'err'
      The status should equal 0
    End

    Example 'can able to change variable.'
      evaluation() { VAR=456; }
      When call evaluation
      The value "$VAR" should equal 456
    End

    Example 'not restore mocked function after evaluation'
      echo_foo() { shellspec_puts 'foo'; }
      mock_foo() { echo_foo() { shellspec_puts 'FOO'; }; }
      When call mock_foo
      The output of 'echo_foo()' should equal 'FOO'
    End

    Example 'calls shellspec_evaluation_cleanup() after evaluation'
      evaluation() { return 123; }
      When invoke shellspec_evaluation_call evaluation
      The stdout should equal 'cleanup: 123'
    End

    Example 'accepts evaluatable string'
      When call 'echo "${*:-}"' 1 2 3
      The stdout should equal '1 2 3'
    End
  End

  Describe 'run evaluation'
    cat() { echo "fake cat"; return 1; }

    Example 'call external command'
      When run cat /dev/null
      The status should equal 0
    End

    Example 'calls shellspec_evaluation_cleanup() after evaluation'
      When invoke shellspec_evaluation_run false
      The stdout should equal 'cleanup: 1'
    End
  End

  Describe 'invoke evaluation'
    Example 'called then retrive stdout and stderr'
      evaluation() { echo ok; echo err >&2; return 0; }
      When invoke evaluation
      The stdout should equal 'ok'
      The stderr should equal 'err'
      The status should equal 0
    End

    Example 'can not able to change variable.'
      evaluation() { VAR=456; }
      When invoke evaluation
      The value "$VAR" should equal 123
    End

    Example 'restore mocked function after evaluation'
      echo_foo() { shellspec_puts 'foo'; }
      mock_foo() { echo_foo() { shellspec_puts 'FOO'; }; }
      When invoke mock_foo
      The output of 'echo_foo()' should equal 'foo'
    End

    Example 'prevent exit.'
      shell_has_bug() {
        # I confirmed zsh 4.2.0. (there may be other things)
        (exit 123) &&:; [ $? -ne 123 ]
      }
      Skip if "can not get the exit status" shell_has_bug

      do_exit() { exit "$1"; }
      When invoke do_exit 12
      The status should equal 12
    End

    Example 'calls shellspec_evaluation_cleanup() after evaluation'
      evaluation() { return 123; }
      When invoke shellspec_evaluation_invoke evaluation
      The stdout should equal 'cleanup: 123'
    End

    Example 'accepts evaluatable string'
      When invoke 'echo "${*:-}"' 1 2 3
      The stdout should equal '1 2 3'
    End
  End

  Describe 'shellspec_evaluation_cleanup()'
    Context 'called with do not outputs anything and returns success'
      evaluation() { return 0; }
      Example 'the switches and outputs are as follows'
        When call evaluation
        The switch UNHANDLED_STATUS should satisfy switch_off
        The switch UNHANDLED_STDOUT should satisfy switch_off
        The switch UNHANDLED_STDERR should satisfy switch_off
        The stdout should equal ''
        The stderr should equal ''
        The status should equal 0
      End
    End

    Context 'called with outputs to stdout and returns success'
      evaluation() { echo ok; return 0; }
      Example 'the switches and outputs are as follows'
        When call evaluation
        The switch UNHANDLED_STATUS should satisfy switch_off
        The switch UNHANDLED_STDOUT should satisfy switch_on
        The switch UNHANDLED_STDERR should satisfy switch_off
        The stdout should equal ok
        The stderr should equal ''
        The status should equal 0
      End
    End

    Context 'called with outputs to stderr and returns success'
      evaluation() { echo err >&2; return 0; }
      Example 'the switches and outputs are as follows'
        When call evaluation
        The switch UNHANDLED_STATUS should satisfy switch_off
        The switch UNHANDLED_STDOUT should satisfy switch_off
        The switch UNHANDLED_STDERR should satisfy switch_on
        The stdout should equal ''
        The stderr should equal 'err'
        The status should equal 0
      End
    End

    Context 'called with outputs to stdout and stderr and returns success'
      evaluation() { echo ok; echo err >&2; return 0; }
      Example 'the switches and outputs are as follows'
        When call evaluation
        The switch UNHANDLED_STATUS should satisfy switch_off
        The switch UNHANDLED_STDOUT should satisfy switch_on
        The switch UNHANDLED_STDERR should satisfy switch_on
        The stdout should equal 'ok'
        The stderr should equal 'err'
        The status should equal 0
      End
    End

    Context 'called with do not outputs anything and returns error'
      evaluation() { return 123; }
      Example 'the switches and outputs are as follows'
        When call evaluation
        The switch UNHANDLED_STATUS should satisfy switch_on
        The switch UNHANDLED_STDOUT should satisfy switch_off
        The switch UNHANDLED_STDERR should satisfy switch_off
        The stdout should equal ''
        The stderr should equal ''
        The status should equal 123
      End
    End

    Context 'called with output to stdout and returns error'
      evaluation() { echo ok; return 123; }
      Example 'the switches and outputs are as follows'
        When call evaluation
        The switch UNHANDLED_STATUS should satisfy switch_on
        The switch UNHANDLED_STDOUT should satisfy switch_on
        The switch UNHANDLED_STDERR should satisfy switch_off
        The stdout should equal 'ok'
        The stderr should equal ''
        The status should equal 123
      End
    End

    Context 'called with output to stderr and returns error'
      evaluation() { echo err >&2; return 123; }
      Example 'the switches and outputs are as follows'
        When call evaluation
        The switch UNHANDLED_STATUS should satisfy switch_on
        The switch UNHANDLED_STDOUT should satisfy switch_off
        The switch UNHANDLED_STDERR should satisfy switch_on
        The stdout should equal ''
        The stderr should equal 'err'
        The status should equal 123
      End
    End

    Context 'called with output to stdout and stderr and returns error'
      evaluation() { echo ok; echo err >&2; return 123; }
      Example 'the switches and outputs are as follows'
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

  Describe 'with Data helper'
    output() { cat -; }

    Describe 'with block'
      Data #comment
        #|aaa
        #|bbb
        #|ccc
        #|
      End

      Example 'reads data as stdin with call evaluation type'
        When call output
        The first line of output should eq 'aaa'
        The second line of output should eq 'bbb'
        The third line of output should eq "ccc"
        The lines of entire output should eq 4
      End

      Example 'reads data as stdin with invoke evaluation type'
        When invoke output
        The first line of output should eq 'aaa'
        The second line of output should eq 'bbb'
        The third line of output should eq "ccc"
        The lines of entire output should eq 4
      End

      Example 'reads data as stdin with run evaluation type'
        When run cat -
        The first line of output should eq 'aaa'
        The second line of output should eq 'bbb'
        The third line of output should eq "ccc"
        The lines of entire output should eq 4
      End
    End

    Describe 'with block with tr filter'
      Data | tr 'abc' 'ABC' # comment
        #|aaa
        #|bbb
        #|ccc
        #|
      End

      Example 'reads data as stdin with filter'
        When call output
        The first line of output should eq 'AAA'
        The second line of output should eq 'BBB'
        The third line of output should eq "CCC"
        The lines of entire output should eq 4
      End
    End

    Describe 'with name'
      func() { printf '%s\n' "$@"; }

      Example 'reads data from function'
        Data func a b c
        When call output
        The first line of output should eq 'a'
        The second line of output should eq 'b'
        The third line of output should eq "c"
        The lines of entire output should eq 3
      End

      Example 'reads data from function with filter'
        Data func a b c | tr 'abc' 'ABC' # comment
        When call output
        The first line of output should eq 'A'
        The second line of output should eq 'B'
        The third line of output should eq "C"
        The lines of entire output should eq 3
      End
    End
  End
End
