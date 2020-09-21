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
      The status should be success
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
      Data printf '\033[1;31m%s\033[0m \033[1;31m%s\033[0m\n' "foo" "bar"
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
    # $1:tick_total $2:time_real $3:profiler_count $4:tick $5:duration
    # duration=$(($2 * $4 / $1))
    callback() { echo "$@"; }

    Data # tick list
      #|1736
      #|2270
      #|2319
      #|2007
      #|1787
    End

    It 'reads profiler.log'
      When call read_profiler callback 84245 1.56 # $3:tick_total $4:time_real
      The line 1 of output should eq "84245 1.56 0 1736 0.0321"
      The line 2 of output should eq "84245 1.56 1 2270 0.0420"
      The line 3 of output should eq "84245 1.56 2 2319 0.0429"
      The line 4 of output should eq "84245 1.56 3 2007 0.0371"
      The line 5 of output should eq "84245 1.56 4 1787 0.0330"
      The variable profiler_count should eq 5
      The variable profiler_tick0 should eq 1736
      The variable profiler_time0 should eq 0.0321
      The variable profiler_tick1 should eq 2270
      The variable profiler_time1 should eq 0.0420
      The variable profiler_tick2 should eq 2319
      The variable profiler_time2 should eq 0.0429
      The variable profiler_tick3 should eq 2007
      The variable profiler_time3 should eq 0.0371
      The variable profiler_tick4 should eq 1787
      The variable profiler_time4 should eq 0.0330
    End
  End

  Describe "quick feature"
    Before init_quick_data

    Describe "init_quick_data()"
      Before quick_data=dummy
      It 'initializes quick data'
        When call init_quick_data
        The variable quick_data should eq ""
      End
    End

    Describe "add_quick_data()"
      It 'adds quick data'
        When call add_quick_data "spec/file1_spec.sh:@1" "failed" y
        The variable quick_data should eq "spec/file1_spec.sh:@1:failed"
      End

      It 'does not add quick data if it not has quick flag'
        When call add_quick_data "spec/file1_spec.sh:@1" "failed"
        The variable quick_data should not eq "spec/file1_spec.sh:@1:failed"
      End

      Context "when already exists quick data"
        setup() { add_quick_data "spec/file1_spec.sh:@1" "failed" y; }
        Before setup

        It 'adds quick data'
          When call add_quick_data "spec/file2_spec.sh:@2" "pending" y
          The line 1 of variable quick_data should eq "spec/file1_spec.sh:@1:failed"
          The line 2 of variable quick_data should eq "spec/file2_spec.sh:@2:pending"
        End
      End
    End

    Describe "eixts_quick_data()"
      It 'returns failure if not exists quick data'
        When call exists_quick_data "spec/file1_spec.sh:@1"
        The status should be failure
      End

      Context "when already exists quick data"
        setup() { add_quick_data "spec/file1_spec.sh:@1" "failed" y; }
        Before setup

        It 'returns success if exists quick data'
          When call exists_quick_data "spec/file1_spec.sh:@1"
          The status should be success
        End
      End
    End

    Describe "filter_quick_file()"
      exists_file() { true; }

      Data
        #|spec/file1_spec.sh:@1:failed
      End

      Context "when file not exists"
        exists_file() { false; }

        It 'removes quick data'
          When call filter_quick_file 1
          The output should eq ""
        End
      End

      It 'preserves quick data if it not matches'
        When call filter_quick_file 1 "spec/file2_spec.sh:@1"
        The output should eq "spec/file1_spec.sh:@1:failed"
      End

      Context 'when add new quick data'
        Before setup
        setup() { add_quick_data "spec/file1_spec.sh:@1" "warned" y; }
        It 'replaces with new quick data'
          When call filter_quick_file 1 "spec/file2_spec.sh:@1"
          The output should eq "spec/file1_spec.sh:@1:warned"
        End
      End

      Context 'when add exists ids'
        Before setup
        setup() { add_quick_data "spec/file1_spec.sh:@1" "succeeded"; }
        It 'does not output anything'
          When call filter_quick_file 1 "spec/file2_spec.sh:@1"
          The output should eq ""
        End
      End

      Context 'when add multiple new quick data'
        Before setup
        setup() {
          add_quick_data "spec/file1_spec.sh:@1" "warned" y
          add_quick_data "spec/file1_spec.sh:@1" "failed" y
        }
        It 'outputs all quick data'
          When call filter_quick_file 1 "spec/file2_spec.sh:@1"
          The line 1 of output should eq "spec/file1_spec.sh:@1:warned"
          The line 2 of output should eq "spec/file1_spec.sh:@1:failed"
        End
      End

      Context 'when no quick data'
        It 'removes quick data of matched path'
          When call filter_quick_file 1 "spec"
          The output should eq ""
        End

        It 'preserves quick data of non-matched path'
          When call filter_quick_file 1 "spec1"
          The output should eq "spec/file1_spec.sh:@1:failed"
        End

        It 'preserves quick data of matched path when not done'
          When call filter_quick_file "" "spec"
          The output should eq "spec/file1_spec.sh:@1:failed"
        End
      End
    End
  End

  Describe "output_trace()"
    Data
      #|trace1
      #|eval : @SHELLSPEC_XTRACE_OFF@
      #|: @SHELLSPEC_XTRACE_OFF@
    End

    It "outputs trace data"
      When call output_trace
      The output should eq "trace1"
    End
  End

  Describe "base26()"
    It "converts to base 26"
      When call base26 ret 703
      The variable ret should eq "aaa"
    End
  End
End
