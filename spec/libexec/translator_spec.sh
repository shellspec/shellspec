#shellcheck shell=sh disable=SC2016

% FIXTURE: "$SHELLSPEC_HELPERDIR/fixture"

Describe "libexec/translator.sh"
  Include "$SHELLSPEC_LIB/libexec/translator.sh"

  Describe "initialize()"
    It 'initializes'
      When run initialize
      The status should be success
    End
  End

  Describe "finalize()"
    BeforeRun initialize
    It 'finalizes'
      BeforeRun mock
      trans() { :; }
      mock() { trans() { echo trans "$@"; }; }
      When run finalize
      The stdout should eq "trans after_block "
      The status should be success
    End

    Context "when inside of example group"
      BeforeRun "block_example_group desc1" "block_example_group desc2" mock
      trans() { :; }
      mock() { trans() { echo trans "$@"; }; }
      syntax_error() { echo "$@"; }
      It 'output syntax error'
        When run finalize
        The line 1 of stdout should eq "Unexpected end of file (expecting 'End')"
        The line 2 of stdout should eq "trans after_block 2"
        The line 3 of stdout should eq "trans block_end"
        The line 4 of stdout should eq "trans after_last_block 1"
        The line 5 of stdout should eq "trans after_block 1"
        The line 6 of stdout should eq "trans block_end"
        The line 7 of stdout should eq "trans after_last_block "
        The line 8 of stdout should eq "trans after_block "
      End
    End
  End

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

      It 'returns success when match pattern'
        BeforeRun "SHELLSPEC_EXAMPLE_FILTER='\$\`ABC'"
        When run check_filter '$`ABC'
        The status should be success
      End

      It 'does not match tag'
        BeforeRun SHELLSPEC_TAG_FILTER="tag"
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
          BeforeRun SHELLSPEC_TAG_FILTER="tag"
          When run check_filter "desc TAG"
          The status should be failure
        End

        It 'returns success when match tag'
          BeforeRun SHELLSPEC_TAG_FILTER="tag"
          When run check_filter "desc tag"
          The status should be success
        End

        It 'returns success when match any tag'
          BeforeRun SHELLSPEC_TAG_FILTER="tag1,tag2"
          When run check_filter "desc tag2"
          The status should be success
        End

        It 'matches tag with value'
          BeforeRun SHELLSPEC_TAG_FILTER="tag"
          When run check_filter "desc tag:value"
          The status should be success
        End
      End

      Context 'when specified tag has a value'
        It 'returns success when match tag'
          BeforeRun SHELLSPEC_TAG_FILTER="tag:value"
          When run check_filter "desc tag:value"
          The status should be success
        End

        It 'does not match tag with different value'
          BeforeRun SHELLSPEC_TAG_FILTER="tag:value1"
          When run check_filter "desc tag:value2"
          The status should be failure
        End

        It 'does not matches tag without value'
          BeforeRun SHELLSPEC_TAG_FILTER="tag:value"
          When run check_filter "desc tag"
          The status should be failure
        End
      End
    End
  End

  Describe "is_constant_name()"
    Parameters
      "FOO" success
      "F1_" success
      "Foo" failure
      "1" failure
    End

    It "checks constant name ($1)"
      When call is_constant_name "$1"
      The status should be "$2"
    End
  End

  Describe "is_function_name()"
    Parameters
      func  success
      FUNC  success
      F1_   success
      Func  success
      1     failure
    End

    It "checks function name ($1)"
      When call is_function_name "$1"
      The status should be "$2"
    End
  End

  Describe "block_example_group()"
    BeforeRun initialize
    trans() { :; }
    mock() {
      block_no='' lineno_begin='' lineno=10 filter=''
      check_filter() { echo "check_filter" "$@"; }
      # shellcheck disable=SC2154
      trans() { "trans_$1" "$@"; }
      trans_before_first_block() {
        echo "before_first_block"
      }
      trans_block_example_group() {
        echo "trans" "$@"
        echo "filter: $filter"
        echo "block_no: $block_no"
        echo "lineno_begin: $lineno_begin"
        case $block_no in
          1) echo "block_lineno_begin1: ${block_lineno_begin1:-}" ;;
          2) echo "block_lineno_begin2: ${block_lineno_begin2:-}" ;;
        esac
      }
    }
    syntax_error() { echo "$@"; }

    Context "when outside of example group"
      BeforeRun mock
      It "generates block_example_group"
        When run block_example_group "desc"
        The line 1 of stdout should eq "check_filter desc"
        The line 2 of stdout should eq "before_first_block"
        The line 3 of stdout should eq "trans block_example_group desc"
        The line 4 of stdout should eq "filter: 1"
        The line 5 of stdout should eq "block_no: 1"
        The line 6 of stdout should eq "lineno_begin: 10"
        The line 7 of stdout should eq "block_lineno_begin1: 10"
      End

      Context 'when filter unmatch'
        BeforeRun mock_filter
        mock_filter() {
          check_filter() { echo "check_filter" "$@"; return 1; }
        }
        It "generates block_example_group"
          When run block_example_group "desc"
          The line 1 of stdout should eq "check_filter desc"
          The line 2 of stdout should eq "before_first_block"
          The line 3 of stdout should eq "trans block_example_group desc"
          The line 4 of stdout should eq "filter: "
          The line 5 of stdout should eq "block_no: 1"
          The line 6 of stdout should eq "lineno_begin: 10"
          The line 7 of stdout should eq "block_lineno_begin1: 10"
        End
      End
    End

    Context "when inside of example group"
      BeforeRun "block_example_group desc1" mock
      It "generates block_example_group"
        When run block_example_group "desc2"
        The line 1 of stdout should eq "check_filter desc2"
        The line 2 of stdout should eq "before_first_block"
        The line 3 of stdout should eq "trans block_example_group desc2"
        The line 4 of stdout should eq "filter: 1"
        The line 5 of stdout should eq "block_no: 2"
        The line 6 of stdout should eq "lineno_begin: 10"
        The line 7 of stdout should eq "block_lineno_begin2: 10"
      End
    End

    Context "when inside of example"
      BeforeRun "block_example desc" mock
      It "outputs syntax error"
        When run block_example_group "desc"
        The stdout should eq 'Describe/Context cannot be defined inside of Example'
      End
    End

    Context "when syntax error"
      one_line_syntax_check() { eval "$1='syntax error'"; return 1; }
      It "outputs syntax error"
        When run block_example_group "desc"
        The stdout should eq 'Describe/Context has occurred an error syntax error'
      End
    End
  End

  Describe "block_example()"
    BeforeRun initialize
    trans() { :; }
    mock() {
      block_no='' lineno_begin='' lineno=10 filter=''
      check_filter() { echo "check_filter" "$@"; }
      # shellcheck disable=SC2154
      trans() { "trans_$1" "$@"; }
      trans_before_first_block() {
        echo "before_first_block"
      }
      trans_block_example() {
        echo "trans" "$@"
        echo "filter: $filter"
        echo "block_no: $block_no"
        echo "lineno_begin: $lineno_begin"
        echo "block_lineno_begin1: $block_lineno_begin1"
      }
    }
    syntax_error() { echo "$@"; }

    Context "when outside of example"
      BeforeRun mock
      It "generates block_example"
        When run block_example "desc"
        The line 1 of stdout should eq "check_filter desc"
        The line 2 of stdout should eq "before_first_block"
        The line 3 of stdout should eq "trans block_example desc"
        The line 4 of stdout should eq "filter: 1"
        The line 5 of stdout should eq "block_no: 1"
        The line 6 of stdout should eq "lineno_begin: 10"
        The line 7 of stdout should eq "block_lineno_begin1: 10"
      End

      Context 'when filter unmatch'
        BeforeRun mock_filter
        mock_filter() {
          check_filter() { echo "check_filter" "$@"; return 1; }
        }
        It "generates block_example_group"
          When run block_example "desc"
          The line 1 of stdout should eq "check_filter desc"
          The line 2 of stdout should eq "before_first_block"
          The line 3 of stdout should eq "trans block_example desc"
          The line 4 of stdout should eq "filter: "
          The line 5 of stdout should eq "block_no: 1"
          The line 6 of stdout should eq "lineno_begin: 10"
          The line 7 of stdout should eq "block_lineno_begin1: 10"
        End
      End
    End

    Context "when inside of example"
      BeforeRun "block_example desc" mock
      It "outputs syntax error"
        When run block_example "desc"
        The stdout should eq 'It/Example/Specify/Todo cannot be defined inside of Example'
      End
    End

    Context "when syntax error"
      one_line_syntax_check() { eval "$1='syntax error'"; return 1; }
      It "outputs syntax error"
        When run block_example "desc"
        The stdout should eq 'It/Example/Specify/Todo has occurred an error syntax error'
      End
    End
  End

  Describe "block_end()"
    BeforeRun initialize
    trans() { :; }
    mock() { trans() { echo trans "$@"; }; }
    syntax_error() { echo "$@"; }
    is_in_ranges() { return 0; }
    remove_from_ranges() { echo "remove_from_ranges"; }

    Context "when inside of block"
      BeforeRun "block_example desc" mock
      It "generate block_end"
        When run block_end "desc"
        The line 1 of stdout should eq "trans after_block 1"
        The line 2 of stdout should eq "remove_from_ranges"
        The line 3 of stdout should eq "trans block_end desc"
      End
    End

    Context "when outside of block"
      It "outputs syntax error"
        When run block_end "desc"
        The stdout should eq "Unexpected 'End'"
      End
    End

    Context "when parameters defined"
      BeforeRun "block_example_group desc" "parameters value" mock
      It "outputs syntax error"
        When run block_end "desc"
        The stdout should eq "Not found any examples. (Missing 'End' of Parameters?)"
      End
    End
  End

  Describe "x()"
    BeforeRun "skip_id=123"
    AfterRun 'foo after_run'
    # shellcheck disable=SC2154
    foo() { echo "$1: skipped: $skipped skipped: $skip_id"; }

    It "skips groups / example"
      When run x foo block
      The line 1 of stdout should eq "block: skipped: 1 skipped: 124"
      The line 2 of stdout should eq "after_run: skipped:  skipped: 124"
    End
  End

  Describe "f()"
    BeforeRun focused='' filter=''
    AfterRun 'foo after_run'
    # shellcheck disable=SC2154
    foo() { echo "$1: focused: $focused filter: $filter"; }

    It "skips groups / example"
      When run f foo block
      The line 1 of stdout should eq "block: focused: focus filter: 1"
      The line 2 of stdout should eq "after_run: focused:  filter: "
    End
  End

  Describe "todo()"
    block_example() { echo block_example "$@"; }
    pending() { echo pending "$@"; }
    block_end() { eval echo block_end ${1+'"$@"'}; }

    It "generates empty example block"
      When run todo desc
      The line 1 of stdout should eq "block_example desc"
      The line 2 of stdout should eq "pending desc"
      The line 3 of stdout should eq "block_end"
    End
  End

  Describe "evaluation()"
    BeforeRun initialize
    trans() { :; }
    mock() { trans() { echo trans "$@"; }; }
    syntax_error() { echo "$@"; }

    Context "when outside of example block"
      It "outputs syntax error"
        When run evaluation syntax
        The stdout should eq "When cannot be defined outside of Example"
      End
    End

    Context "when inside of example block"
      BeforeRun "block_example desc" mock
      It "generates evaluation"
        When run evaluation syntax
        The stdout should eq "trans evaluation syntax"
      End
    End
  End

  Describe "expectation()"
    BeforeRun initialize
    trans() { :; }
    mock() { trans() { echo trans "$@"; }; }
    syntax_error() { echo "$@"; }

    Context "when outside of example block"
      It "outputs syntax error"
        When run expectation syntax
        The stdout should eq "The cannot be defined outside of Example"
      End
    End

    Context "when inside of example block"
      BeforeRun "block_example desc" mock
      It "generates expectation"
        When run expectation syntax
        The stdout should eq "trans expectation syntax"
      End
    End
  End

  Describe "example_hook()"
    BeforeRun initialize
    trans() { :; }
    mock() { trans() { echo trans "$@"; }; }
    syntax_error() { echo "$@"; }

    Context "when outside of example block"
      BeforeRun mock
      It "generates before/after hook"
        When run example_hook "before/after"
        The stdout should eq "trans control before/after"
      End
    End

    Context "when inside of example block"
      BeforeRun "block_example desc" mock
      It "outputs syntax error"
        When run example_hook syntax
        The stdout should eq "Before/After cannot be defined inside of Example"
      End
    End
  End

  Describe "example_all_hook()"
    BeforeRun initialize
    trans() { :; }
    mock() { trans() { echo trans "$@"; }; }
    syntax_error() { echo "$@"; }

    Context "when outside of example block"
      BeforeRun mock
      It "generates before/after all hook"
        When run example_all_hook "before/after all"
        The stdout should eq "trans control before/after all"
      End
    End

    Context "when inside of example block"
      BeforeRun "block_example desc" mock
      It "outputs syntax error"
        When run example_all_hook syntax
        The stdout should eq "BeforeAll/AfterAll cannot be defined inside of Example"
      End
    End

    Context "when after example block"
      BeforeRun "block_example desc"
      BeforeRun "block_end"
      It "outputs syntax error"
        When run example_all_hook before_all
        The stdout should eq "BeforeAll cannot be defined after of Example Group/Example in same block"
      End
    End
  End

  Describe "control()"
    BeforeRun initialize
    trans() { echo trans "$@"; }

    It "generates control statement"
      When run control statement
      The stdout should eq "trans control statement"
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
      The line 2 of stdout should eq "embedded_text_begin ==== "
      The line 3 of stdout should eq "embedded_text_line aaa"
      The line 4 of stdout should eq "embedded_text_end"
      The line 5 of stdout should eq "data_end ===="
    End

    It "reads text data (with comment)"
      When run _data "====" "# comment"
      The line 1 of stdout should eq "data_begin ==== # comment"
      The line 2 of stdout should eq "embedded_text_begin ==== # comment"
      The line 3 of stdout should eq "embedded_text_line aaa"
      The line 4 of stdout should eq "embedded_text_end"
      The line 5 of stdout should eq "data_end ==== # comment"
    End

    It "reads text data (with filter)"
      When run _data "====" "| tr"
      The line 1 of stdout should eq "data_begin ==== | tr"
      The line 2 of stdout should eq "embedded_text_begin ==== | tr"
      The line 3 of stdout should eq "embedded_text_line aaa"
      The line 4 of stdout should eq "embedded_text_end"
      The line 5 of stdout should eq "data_end ==== | tr"
    End

    It "outputs error with invalid line"
      _data() { echo "error" | data "$@"; }
      syntax_error() { echo "$@"; }
      When run _data "===="
      The line 1 of stdout should eq "data_begin ===="
      The line 2 of stdout should eq "embedded_text_begin ==== "
      The line 3 of stdout should eq "embedded_text_end"
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

  Describe "text_begin()"
    BeforeRun initialize
    trans() { echo trans "$@"; }

    It "generates the beginning of text lines"
      When run text_begin "text"
      The stdout should eq "trans embedded_text_begin text"
    End
  End

  Describe "text_line()"
    BeforeRun initialize
    trans() { echo trans "$@"; }

    It "generates text line"
      When run text_line "#|text"
      The stdout should eq "trans embedded_text_line text"
    End

    It "generates the end of text lines"
      When run text_line "echo test"
      The stdout should eq "trans embedded_text_end"
      The status should be failure
    End
  End

  Describe "text_end()"
    BeforeRun initialize
    trans() { echo trans "$@"; }

    It "generates the the of text lines"
      When run text_end "text"
      The stdout should eq "trans embedded_text_end text"
    End
  End

  Describe "parameters()"
    BeforeRun initialize
    trans() { :; }
    mock() { trans() { echo trans "$@"; }; }
    parameters_value() { echo parameters_value; }
    syntax_error() { echo "$@"; }

    Context "when outside of example block"
      BeforeRun mock
      It "generates parameters"
        When run parameters value
        The line 1 of stdout should eq "trans parameters_begin 1"
        The line 2 of stdout should eq "parameters_value"
        The line 3 of stdout should eq "trans parameters_end"
      End
    End

    Context "when inside of example block"
      BeforeRun "block_example desc" mock
      It "generates parameters"
        When run parameters value
        The stdout should eq "Parameters cannot be defined inside of Example"
      End
    End
  End

  Describe "parameters_block()"
    BeforeRun initialize setup
    AfterRun check
    trans() { echo trans "$@"; }
    setup() { parameter_count=0; }
    check() { echo "parameter_count: $parameter_count"; }

    Data
      #|  a \
      #|    a1
      #|  # comment
      #|  b
      #|
      #|  c
      #|End
    End

    It "generates parameters (block)"
      When run parameters_block a b c
      The line 1 of stdout should eq "trans parameters a \\"
      The line 2 of stdout should eq "trans line     a1"
      The line 3 of stdout should eq 'trans parameters b'
      The line 4 of stdout should eq "trans parameters c"
      The line 5 of stdout should eq "parameter_count: 3"
    End
  End

  Describe "parameters_value()"
    BeforeRun initialize setup
    AfterRun check
    trans() { echo trans "$@"; }
    setup() { parameter_count=0; }
    check() { echo "parameter_count: $parameter_count"; }

    It "generates parameters (value)"
      When run parameters_value a b c
      The line 1 of stdout should eq "trans line for shellspec_matrix in a b c; do"
      The line 2 of stdout should eq 'trans parameters "$shellspec_matrix"'
      The line 3 of stdout should eq "trans line done"
      The line 4 of stdout should eq "parameter_count: 3"
    End
  End

  Describe "parameters_matrix()"
    BeforeRun initialize setup
    AfterRun check
    trans() { echo trans "$@"; }
    setup() { parameter_count=0; }
    check() { echo "parameter_count: $parameter_count"; }

    Data
      #|  foo bar baz qux
      #|  # comment
      #|  1 2 3
      #|
      #|  A B
      #|End
    End

    It "generates parameters (matrix)"
      When run parameters_matrix
      The line  1 of stdout should eq "trans line for shellspec_matrix1 in foo bar baz qux"
      The line  2 of stdout should eq "trans line do"
      The line  3 of stdout should eq 'trans line for shellspec_matrix2 in 1 2 3'
      The line  4 of stdout should eq "trans line do"
      The line  5 of stdout should eq "trans line for shellspec_matrix3 in A B"
      The line  6 of stdout should eq "trans line do"
      The line  7 of stdout should eq 'trans parameters "$shellspec_matrix1" "$shellspec_matrix2" "$shellspec_matrix3" '
      The line  8 of stdout should eq "trans line done"
      The line  9 of stdout should eq "trans line done"
      The line 10 of stdout should eq "trans line done"
      The line 11 of stdout should eq "parameter_count: 24" # 4 * 3 * 2
    End
  End

  Describe "parameters_dynamic()"
    BeforeRun initialize setup
    AfterRun check
    trans() { echo trans "$@"; }
    setup() { parameter_count=0; }
    check() { echo "parameter_count: $parameter_count"; }

    Data
      #|  for i in 1 2; do
      #|  %data foo bar baz
      #|  %data 1 2 3
      #|  done
      #|End
    End

    It "generates parameters (value)"
      When run parameters_dynamic
      The line 1 of stdout should eq "trans line for i in 1 2; do"
      The line 2 of stdout should eq "trans parameters  foo bar baz"
      The line 3 of stdout should eq "trans parameters  1 2 3"
      The line 4 of stdout should eq "trans line done"
      The line 5 of stdout should eq "parameter_count: 4"
    End
  End

  Describe "mock()"
    BeforeRun initialize
    trans() { :; }
    mock_trans() { trans() { echo trans "$@"; }; }
    syntax_error() { echo "$@"; }

    BeforeRun mock_trans

    It "outputs syntax error"
      When run mock "desc"
      The stdout should eq 'trans mock_begin desc'
    End
  End

  Describe "constant()"
    BeforeRun initialize
    trans() { :; }
    mock() { trans() { echo trans "$@"; }; }
    syntax_error() { echo "$@"; }

    Context "when outside of example block"
      BeforeRun mock

      It "generates constant definition"
        When run constant "FOO: value"
        The stdout should eq "trans constant FOO value"
      End

      It "output error with invalid constant name"
        When run constant "foo: value"
        The stdout should eq "Constant name should match pattern [A-Z_][A-Z0-9_]*"
      End
    End

    Context "when inside of example block"
      BeforeRun "block_example desc" mock
      It "outputs syntax error"
        When run constant "FOO: value"
        The stdout should eq "Constant should be defined outside of Example Group/Example"
      End
    End
  End

  Describe "include()"
    BeforeRun initialize
    trans() { :; }
    mock() { trans() { echo trans "$@"; }; }
    syntax_error() { echo "$@"; }

    Context "when outside of example block"
      BeforeRun mock

      It "generates constant definition"
        When run include "./script.sh"
        The stdout should eq "trans include ./script.sh"
      End

      Context "when syntax error"
        one_line_syntax_check() { eval "$1='syntax error'"; return 1; }
        It "outputs syntax error"
          When run include "'./script.sh"
          The stdout should eq 'Include has occurred an error syntax error'
        End
      End
    End

    Context "when inside of example block"
      BeforeRun "block_example desc" mock
      It "outputs syntax error"
        When run include "./script.sh"
        The stdout should eq "Include cannot be defined inside of Example"
      End
    End

  End

  Describe "with_function()"
    trans() { echo trans "$@"; }
    foo() { echo "$@"; }

    It "generates function and syntax"
      When run with_function "syntax" foo putsn bar
      The line 1 of stdout should eq "trans with_function syntax"
      The line 2 of stdout should eq "putsn bar"
    End
  End

  Describe "out()"
    trans() { echo trans "$@"; }

    It "generates as is"
      When run out "code"
      The stdout should eq "trans out code"
    End
  End

  Describe "is_in_range()"
    Context "when block id specified"
      Parameters
        @12 success
        @22 failure
      End

      It "checks if block id is match (currnet block id: 12, block_id: $1)"
        BeforeRun block_id=12
        When run is_in_range "$1"
        The status should be "$2"
      End
    End

    Context "when lineno specified"
      Parameters
        10 failure
        11 success
        15 success
        16 failure
      End

      It "checks if line no is in range (lineno range: 11-15, lineno: $1)"
        BeforeRun lineno_begin=11 lineno_end=15
        When run is_in_range "$1"
        The status should be "$2"
      End
    End
  End

  Describe "is_in_ranges()"
    Context "when ranges not specified"
      BeforeRun ranges=''

      It "returns failure"
        When run is_in_ranges
        The status should be failure
      End
    End

    Context "when ranges specified"
      BeforeRun "ranges='1 2 3'"

      It "returns success if match any ranges"
        is_in_range() { printf "%s " "$1"; }
        When run is_in_ranges
        The stdout should eq "1 "
        The status should be success
      End

      It "returns failure if not match any ranges"
        is_in_range() { printf "%s " "$1"; return 1; }
        When run is_in_ranges
        The stdout should eq "1 2 3 "
        The status should be failure
      End
    End
  End

  Describe "remove_from_ranges()"
    BeforeRun "ranges='1 2 3 1 2 3'"
    AfterRun 'echo $ranges'

    It "removes matched range"
      is_in_range() { [ "$1" = "2" ]; }
      When run remove_from_ranges
      The stdout should eq "1 3 1 3 "
    End
  End

  Describe "translate()"
    BeforeRun initialize
    trans() { echo trans "$@"; }
    mapping() {
      case $1 in
        DSL) echo "translated $1" ;;
        %text) text_begin ;;
        *) return 1 ;;
      esac
    }

    Data
      #|line1 \
      #|line2
      #|DSL
      #|line3
      #|%text
      #|#|text1
      #|#|text2
      #|line4
    End

    It "translates specfile"
      When run translate
      The line 1 of stdout should eq "trans line line1 \\"
      The line 2 of stdout should eq "line2"
      The line 3 of stdout should eq "translated DSL"
      The line 4 of stdout should eq "trans line line3"
      The line 5 of stdout should eq "trans embedded_text_begin"
      The line 6 of stdout should eq "trans embedded_text_line text1"
      The line 7 of stdout should eq "trans embedded_text_line text2"
      The line 8 of stdout should eq "trans embedded_text_end"
      The line 9 of stdout should eq "trans line line4"
    End
  End

  Describe "translate_mock()"
    Before initialize
    trans() { echo trans "$@"; }
    syntax_error() { echo "syntax error" "$@"; }

    Context "when inside mock"
      Before "inside_of_mock=1"

      It "returns success if DSL is End"
        When call translate_mock "End"
        The stdout should eq "trans mock_end End"
        The status should be success
      End

      It "returns success with error if specified DSL"
        When call translate_mock "It"
        The stdout should be blank
        The status should be success
        The variable use_dsl_in_mock should eq 1
      End
    End

    Context "when outside mock"
      Before "inside_of_mock="

      It "returns false"
        When call translate_mock "foo"
        The status should be failure
      End

      It "raises syntax error"
        BeforeCall "use_dsl_in_mock=1"
        When call translate_mock "foo"
        The output should eq "syntax error Only directives can be used in Mock"
        The status should be failure
      End
    End
  End
End
