#shellcheck shell=sh

% FILE: "$SHELLSPEC_SPECDIR/fixture/time_log.txt"

Describe "libexec/reporter.sh"
  Include "$SHELLSPEC_LIB/libexec/reporter.sh"

  Describe "read_time_log()"
    It "does not read anything if file missing"
      When call read_time_log prefix "$FILE.not-exits"
      The variable prefix_real should be undefined
      The variable prefix_user should be undefined
      The variable prefix_sys should be undefined
      The status should be success
    End

    It "reads log data if file exists"
      When call read_time_log prefix "$FILE"
      The variable prefix_real should equal 1.23
      The variable prefix_user should equal 0.11
      The variable prefix_sys should equal 12.45
      The variable prefix_ should be undefined
      The status should be success
    End
  End

  Describe "buffer()"
    Before 'buffer example'

    Context 'when initial state'
      It 'is not present'
        When call example '?'
        The status should not be success
      End

      It 'is empty'
        When call example '!?'
        The status should be success
      End

      It 'is not open'
        The variable example_opened should eq ''
      End

      It 'is not flowed'
        The variable example_flowed should eq ''
      End
    End

    Context 'when something is in the buffer'
      Before 'example = foo'

      It 'is present'
        When call example '?'
        The status should be success
      End

      It 'is not empty'
        When call example '!?'
        The status should not be success
      End
    End

    Describe "="
      It 'sets to the buffer and opened'
        When call example '=' 'foo' 'bar'
        The variable example_buffer should eq 'foo bar'
        The variable example_opened should be present
      End
    End

    Describe "|="
      Context 'when the buffer is empty'
        It 'sets to the buffer and opened'
          When call example '|=' 'foo' 'bar'
          The variable example_buffer should eq 'foo bar'
          The variable example_opened should be present
        End
      End

      Context 'when the buffer is not empty'
        Before 'example = foo'

        It 'not sets to the buffer and opened'
          When call example '|=' 'bar' 'baz'
          The variable example_buffer should eq 'foo'
          The variable example_opened should be present
        End
      End
    End

    Describe "+="
      Context 'when the buffer is empty'
        It 'sets to the buffer and opened'
          When call example '+=' 'foo' 'bar'
          The variable example_buffer should eq 'foo bar'
          The variable example_opened should be present
        End
      End

      Context 'when the buffer is not empty'
        Before 'example = foo'
        It 'not sets to the buffer and opened'
          When call example '+=' 'bar' 'baz'
          The variable example_buffer should eq 'foobar baz'
          The variable example_opened should be present
        End
      End
    End

    Describe "<|>"
      It 'opens the buffer'
        When call example '<|>'
        The variable example_opened should be present
      End
    End

    Describe ">|<"
      Before 'example = foo'

      It 'closes the buffer'
        When call example '>|<'
        The variable example_opened should eq ''
      End

      Context 'when not flowed'
        It 'does not clear the buffer'
          When call example '>|<'
          The variable example_buffer should eq 'foo'
          The variable example_flowed should eq ''
          The variable example_opened should eq ''
        End
      End

      Context 'when flowed'
        Before 'example ">>>" >/dev/null'

        It 'clears the buffer'
          When call example '>|<'
          The variable example_buffer should eq ''
          The variable example_flowed should eq ''
          The variable example_opened should eq ''
        End
      End
    End

    Describe ">>>"
      Before 'example = foo'

      Context 'when the buffer is open'
        It 'outputs the buffer'
          When call example '>>>'
          The output should eq 'foo'
        End

        It 'outputs same things'
          output_twice() { example '>>>'; example '>>>'; }
          When call output_twice
          The output should eq 'foofoo'
          The variable example_flowed should be present
        End
      End

      Context 'when the buffer is close'
        Before 'example ">|<"'

        It 'not outputs the buffer'
          When call example '>>>'
          The output should eq ''
          The variable example_flowed should be blank
        End
      End
    End
  End
End
