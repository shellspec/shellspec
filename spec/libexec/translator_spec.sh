#shellcheck shell=sh disable=SC2016

% FIXTURE: "$SHELLSPEC_SPECDIR/fixture"

Describe "libexec/translator.sh"
  Include "$SHELLSPEC_LIB/libexec/translator.sh"

  Describe "read_specfile()"
    process() {
      lineno=0 line=''
      while read_specfile line; do
        echo "$line"
      done < "$1"
      echo "$lineno"
    }

    It 'reads file'
      When run process "$FIXTURE/specfile-lf.txt"
      The line 1 of stdout should eq foo
      The line 2 of stdout should eq bar
      The line 3 of stdout should eq baz
      The line 4 of stdout should eq 3
    End

    It 'reads file which windows line endings'
      When run process "$FIXTURE/specfile-crlf.txt"
      The line 1 of stdout should eq foo
      The line 2 of stdout should eq bar
      The line 3 of stdout should eq baz
      The line 4 of stdout should eq 3
    End
  End

  Describe "check_filter()"
    Context 'when no description'
      It 'returns failure'
        When run check_filter ""
        The status should be failure
      End
    End

    Context 'when description only'
      BeforeRun 'SHELLSPEC_TAG_FILTER='

      It 'returns failure when not match pattern'
        BeforeRun SHELLSPEC_EXAMPLE_FILTER="dummy"
        When run check_filter "test"
        The status should be failure
      End

      It 'returns success when match pattern'
        BeforeRun SHELLSPEC_EXAMPLE_FILTER="foo*"
        When run check_filter "foobar"
        The status should be success
      End

      It 'does not match tag'
        BeforeRun SHELLSPEC_TAG_FILTER=",tag,"
        When run check_filter "desc"
        The status should be failure
      End

      It 'does not cause an error use the variable'
        BeforeRun 'unset no_such_variable ||:'
        When run check_filter '"desc $no_such_variable"'
        The status should be failure
      End
    End

    Context 'when tag exists'
      BeforeRun 'SHELLSPEC_EXAMPLE_FILTER='

      Context 'when specified tag has no value'
        It 'returns failure when not match tag'
          BeforeRun SHELLSPEC_TAG_FILTER=",tag,"
          When run check_filter "desc TAG"
          The status should be failure
        End

        It 'returns success when match tag'
          BeforeRun SHELLSPEC_TAG_FILTER=",tag,"
          When run check_filter "desc tag"
          The status should be success
        End

        It 'returns success when match any tag'
          BeforeRun SHELLSPEC_TAG_FILTER=",tag1,tag2,"
          When run check_filter "desc tag2"
          The status should be success
        End

        It 'matches tag with value'
          BeforeRun SHELLSPEC_TAG_FILTER=",tag,"
          When run check_filter "desc tag:value"
          The status should be success
        End
      End

      Context 'when specified tag has a value'
        It 'returns success when match tag'
          BeforeRun SHELLSPEC_TAG_FILTER=",tag:value,"
          When run check_filter "desc tag:value"
          The status should be success
        End

        It 'does not match tag with different value'
          BeforeRun SHELLSPEC_TAG_FILTER=",tag:value1,"
          When run check_filter "desc tag:value2"
          The status should be failure
        End

        It 'does not matches tag without value'
          BeforeRun SHELLSPEC_TAG_FILTER=",tag:value,"
          When run check_filter "desc tag"
          The status should be failure
        End
      End
    End
  End

  Describe "escape_one_line_syntax()"
    It 'escapes $ and `'
      When call escape_one_line_syntax desc '$foo `bar`'
      The variable desc should eq '\$foo \`bar\`'
    End

    It 'escapes $ and ` inside of double qoute'
      When call escape_one_line_syntax desc '"$foo" `bar`'
      The variable desc should eq '"\$foo" \`bar\`'
    End

    It 'does not escape $ inside of single quote'
      When call escape_one_line_syntax desc "'\$foo' bar"
      The variable desc should eq "'\$foo' bar"
    End

    It 'does not escape meta character'
      When call escape_one_line_syntax desc "var[2] * ? \\ end"
      The variable desc should eq "var[2] * ? \\ end"
    End
  End

  Describe "pending()"
    trans() { echo "$@"; }

    It "translates pending"
      When run pending
      The stdout should eq "pending"
    End

    It "translates pending with message"
      When run pending "message"
      The stdout should eq "pending message"
    End

    It "translates pending with comment"
      When run pending "#comment"
      The stdout should eq "pending '# comment'"
    End
  End

  Describe "skip()"
    BeforeRun skip_id=12345
    trans() { echo "$@"; }
    AfterRun 'echo $skip_id'

    It "translates skip"
      When run skip
      The line 1 of stdout should eq skip
      The line 2 of stdout should eq 12346
    End

    It "translates skip with comment"
      When run skip "#comment"
      The line 1 of stdout should eq "skip '# comment'"
      The line 2 of stdout should eq 12346
    End
  End

  Describe "data()"
    BeforeRun lineno=12345
    trans() { echo "$@"; }

    _data() {
      {
        echo "# comment"
        echo "#|aaa"
      } | data "$@"
    }

    It "reads text data"
      When run _data "===="
      The line 1 of stdout should eq "data_begin ===="
      The line 2 of stdout should eq "data_here_begin ==== "
      The line 3 of stdout should eq "data_here_line #|aaa"
      The line 4 of stdout should eq "data_here_end"
      The line 5 of stdout should eq "data_end ===="
    End

    It "reads text data (with comment)"
      When run _data "====" "# comment"
      The line 1 of stdout should eq "data_begin ==== # comment"
      The line 2 of stdout should eq "data_here_begin ==== # comment"
      The line 3 of stdout should eq "data_here_line #|aaa"
      The line 4 of stdout should eq "data_here_end"
      The line 5 of stdout should eq "data_end ==== # comment"
    End

    It "reads text data (with filter)"
      When run _data "====" "| tr"
      The line 1 of stdout should eq "data_begin ==== | tr"
      The line 2 of stdout should eq "data_here_begin ==== | tr"
      The line 3 of stdout should eq "data_here_line #|aaa"
      The line 4 of stdout should eq "data_here_end"
      The line 5 of stdout should eq "data_end ==== | tr"
    End

    It "outputs error with invalid line"
      _data() { echo "error" | data "$@"; }
      syntax_error() { echo "$@"; }
      When run _data "===="
      The line 1 of stdout should eq "data_begin ===="
      The line 2 of stdout should eq "data_here_begin ==== "
      The line 3 of stdout should eq "data_here_end"
      The line 4 of stdout should eq "Data text should begin with '#|' or '# '"
      The line 5 of stdout should eq "data_end ===="
    End

    It "reads text data from quoted argument"
      When run data "====" "'string'"
      The line 1 of stdout should eq "data_begin ==== 'string'"
      The line 2 of stdout should eq "data_text 'string'"
      The line 3 of stdout should eq "data_end ==== 'string'"
    End

    It "reads text data from double quoted argument"
      When run data "====" "\"string\""
      The line 1 of stdout should eq "data_begin ==== \"string\""
      The line 2 of stdout should eq "data_text \"string\""
      The line 3 of stdout should eq "data_end ==== \"string\""
    End

    It "reads text data from function"
      When run data "====" "func"
      The line 1 of stdout should eq "data_begin ==== func"
      The line 2 of stdout should eq "data_func func"
      The line 3 of stdout should eq "data_end ==== func"
    End

    It "reads text data from file"
      When run data "====" "< file"
      The line 1 of stdout should eq "data_begin ==== < file"
      The line 2 of stdout should eq "data_file < file"
      The line 3 of stdout should eq "data_end ==== < file"
    End
  End
End
