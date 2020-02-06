#shellcheck shell=sh disable=SC2004,SC2016

% FILE: "$SHELLSPEC_SPECDIR/fixture/time_log.txt"
% PROFILER_LOG: "$SHELLSPEC_SPECDIR/fixture/profiler/profiler.log"

Describe "libexec/reporter.sh"
  Include "$SHELLSPEC_LIB/libexec/reporter.sh"

  Describe "count()"
    fake_list() { echo '10 100'; }
    Before SHELLSPEC_SHELL="fake_list"

    It 'counts examples'
      When call count spec
      The variable count_specfiles should eq 10
      The variable count_examples should eq 100
    End
  End

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

  Describe "field_description()"
    Before 'field_description="foo${VT}bar${VT}baz"'

    It 'outputs field_description split by space'
      When call field_description
      The output should eq "foo bar baz"
    End
  End

  Describe "buffer()"
    It 'creates buffer'
      When call buffer example
      The result of 'example()' should eq ''
    End
  End

  Describe "buffer functions"
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

  Describe "xmlescape()"
    It 'escapes special characters'
      When call xmlescape value '<"test&">'
      The variable value should eq '&lt;&quot;test&amp;&quot;&gt;'
    End
  End

  Describe "xmlattrs()"
    It 'creates xml attributes'
      When call xmlattrs attrs 'v1=a' 'v2=<"test&">'
      The variable attrs should eq 'v1="a" v2="&lt;&quot;test&amp;&quot;&gt;"'
    End
  End

  Describe "remove_escape_sequence()"
    It 'removes escape sequence'
      Data printf '\033[2;31m%s\033[0m \033[2;31m%s\033[0m\n' "foo" "bar"
      When call remove_escape_sequence
      The stdout should eq "foo bar"
    End
  End

  Describe "inc()"
    Before value1=0 value2=1
    It 'increments variables'
      When call inc value1 value2
      The variable value1 should eq 1
      The variable value2 should eq 2
    End
  End

  Describe "read_profiler()"
    BeforeCall index_total=0 tick_total=0 duration_total=0
    AfterCall 'shellspec_shift10 duration_total "$duration_total" -4'

    callback() {
      index=$1 tick=$2 duration=$3
      index_total=$(($index_total + $index))
      tick_total=$(($tick_total + $tick))
      shellspec_shift10 duration "$duration" 4
      duration_total=$(($duration_total + $duration))
    }

    It 'reads profiler.log'
      When call read_profiler callback "$PROFILER_LOG" "13.56"
      The variable index_total should eq 174345
      The variable tick_total should eq 1381353
      The variable duration_total should eq 6.6802
    End
  End
End
