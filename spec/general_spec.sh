#shellcheck shell=sh disable=SC2016

% FILE: "$SHELLSPEC_SPECDIR/fixture/end-with-multiple-lf.txt"

Describe "general.sh"
  Describe 'shellspec_reset_params()'
    reset_params() {
      shellspec_reset_params "$1" "$2"
      eval "$SHELLSPEC_RESET_PARAMS"
      printf '%s\n' "$@"
    }

    It "separates by \"'\""
      When call reset_params '$3' "'" "a'b'c"
      The first  line of stdout should equal 'a'
      The second line of stdout should equal 'b'
      The third  line of stdout should equal 'c'
    End

    It 'separates by ":" (fourth argument only)'
      When call reset_params '"$3" $4' : "1:2:3" "a:b:c"
      The stdout line 1 should equal '1:2:3'
      The stdout line 2 should end with 'a'
      The stdout line 3 should equal 'b'
      The stdout line 4 should equal 'c'
    End
  End

  Describe 'shellspec_splice_params()'
    splice() {
      params=$1
      shift
      args=$*
      eval "set -- $params"
      eval "shellspec_splice_params $# $args"
      eval "$SHELLSPEC_RESET_PARAMS"
      echo "${*:-}"
    }

    Context 'when offset is 0'
      It 'removes all parameters'
        When call splice "a b c d e f g" 0
        The stdout should equal ""
      End
    End

    Context 'when offset is 2'
      It 'removes all parameters after offset 2'
        When call splice "a b c d e f g" 2
        The stdout should equal 'a b'
      End
    End

    Context 'when offset is 3 and length is 2'
      It 'removes 2 parameters after offset 3'
        When call splice "a b c d e f g" 3 2
        The stdout should equal 'a b c f g'
      End
    End

    Context 'when offset is 3 and length is 2 and list specified'
      Before 'a=A b=B c=C'
      It 'removes 2 parameters after offset 3 and inserts list'
        When call splice "a b c d e f g" 3 2 a b c
        The stdout should equal 'a b c A B C f g'
      End
    End
  End

  Describe 'shellspec_each()'
    callback() { echo "$1:$2:$3"; }

    It 'calls callback with index and value'
      When call shellspec_each callback a b c
      The stdout should equal "a:1:3${LF}b:2:3${LF}c:3:3"
    End

    It 'calls callback with no params'
      When call shellspec_each callback
      The stdout should equal ""
    End
  End

  Describe 'shellspec_find()'
    callback() { case $1 in (a*) return 0; esac; return 1; }

    _find() {
      shellspec_find callback "$@"
      eval "$SHELLSPEC_RESET_PARAMS"
      shellspec_puts "$@"
    }

    It 'calls callback with index and value'
      When call _find a1 b1 c1 a2 b2 c2 a3 b3 c3
      The stdout should equal "a1 a2 a3"
    End
  End

  Describe 'shellspec_sequence()'
    callback() { shellspec_puts "$1,"; }

    It 'calls callback with sequence of numbers'
      When call shellspec_sequence callback 1 5
      The stdout should equal "1,2,3,4,5,"
    End

    It 'calls callback with sequence of numbers with step N'
      When call shellspec_sequence callback 1 5 2
      The stdout should equal "1,3,5,"
    End

    It 'calls callback with reversed sequence of numbers'
      When call shellspec_sequence callback 5 1
      The stdout should equal "5,4,3,2,1,"
    End

    It 'calls callback with reversed sequence of numbers with step N'
      When call shellspec_sequence callback 5 1 -2
      The stdout should equal "5,3,1,"
    End
  End

  Describe 'shellspec_puts()'
    It 'does not output anything without arguments'
      When call shellspec_puts
      The entire stdout should equal ''
    End

    It 'outputs arguments'
      When call shellspec_puts 'a'
      The entire stdout should equal 'a'
    End

    It 'joins arguments with space and outputs'
      When call shellspec_puts 'a' 'b'
      The entire stdout should equal 'a b'
    End

    It 'outputs with raw string'
      When call shellspec_puts 'a\b'
      The entire stdout should equal 'a\b'
      The length of entire stdout should equal 3
    End

    It 'outputs "-n"'
      When call shellspec_puts -n
      The entire stdout should equal '-n'
    End

    Context 'when change IFS'
      Before 'IFS=@'
      It 'joins arguments with spaces'
        When call shellspec_puts a b c
        The entire stdout should equal 'a b c'
      End
    End
  End

  Describe 'shellspec_putsn()'
    It 'does not output anything without arguments'
      When call shellspec_putsn
      The entire stdout should equal "${LF}"
    End

    It 'outputs append with LF'
      When call shellspec_putsn "a"
      The entire stdout should equal "a${LF}"
    End

    It 'joins arguments with space and outputs append with LF'
      When call shellspec_putsn "a" "b"
      The entire stdout should equal "a b${LF}"
    End

    It 'outputs with raw string append with LF'
      When call shellspec_putsn 'a\b'
      The entire stdout should equal "a\\b${LF}"
      The length of entire stdout should equal 4
    End

    Context 'when change IFS'
      Before 'IFS=@'
      It 'joins arguments with spaces'
        When call shellspec_putsn a b c
        The entire stdout should equal "a b c${LF}"
      End
    End
  End

  Describe 'shellspec_escape_quote()'
    example() {
      var=$1
      shellspec_escape_quote var
      eval "ret='$var'"
    }

    It 'returns escaped string that evaluatable by eval'
      When call example "te'st"
      The variable ret should equal "te'st"
    End
  End

  Describe 'shellspec_lines()'
    callback() { printf '%s ' "$2:$1"; }
    callback_with_cancel() { printf '%s ' "$2:$1"; return 1; }

    It 'does not call callback with empty string'
      When call shellspec_lines callback ""
      The stdout should eq ""
    End

    It 'calls callback by each line'
      When call shellspec_lines callback "a${LF}b"
      The stdout should eq "1:a 2:b "
    End

    It 'ignores last LF'
      When call shellspec_lines callback "a${LF}b${LF}"
      The stdout should eq "1:a 2:b "
    End

    It 'can cancels calls of callback.'
      When call shellspec_lines callback_with_cancel "a${LF}b"
      The stdout should eq "1:a "
    End
  End

  Describe "shellspec_padding()"
    It "paddings with @"
      When call shellspec_padding str "@" 10
      The variable str should equal '@@@@@@@@@@'
    End
  End

  Describe "shellspec_includes()"
    It "returns success if includes value"
      When call shellspec_includes "abc" "b"
      The status should be success
    End

    It "returns failure if not includes value"
      When call shellspec_includes "abc" "d"
      The status should be failure
    End

    It "treats | as not meta character"
      When call shellspec_includes "a|b|c" "|b|"
      The status should be success
    End

    It "treats * as not meta character"
      When call shellspec_includes "abc" "*"
      The status should be failure
    End

    It "treats ? as not meta character"
      When call shellspec_includes "abc" "?"
      The status should be failure
    End

    It "treats [] as not meta character"
      When call shellspec_includes "abc[d]" "c[d]"
      The status should be success
    End

    It "treats \" as not meta character"
      When call shellspec_includes "a\"c" '"'
      The status should be success
    End
  End

  Describe 'shellspec_passthrough()'
    passthrough() {
      shellspec_puts "$1" | shellspec_passthrough
    }

    It "passes through to stdout from stdin"
      When call passthrough "a${SHELLSPEC_LF}b${SHELLSPEC_LF}"
      The entire output should equal "a${SHELLSPEC_LF}b${SHELLSPEC_LF}"
    End

    It "passes through data that not end with LF"
      When call passthrough "a${SHELLSPEC_LF}b"
      The entire output should equal "a${SHELLSPEC_LF}b"
    End
  End

  Describe 'shellspec_readfile()'
    It 'reads the file as is'
      When call shellspec_readfile var "$FILE"
      The variable var should equal "a${LF}${LF}"
    End
  End

  Describe "shellspec_trim()"
    Before set_value

    Context 'when value is abc'
      set_value() { value="  abc"; }
      It 'trims left space'
        When call shellspec_trim value
        The value "$value" should eq 'abc'
      End
    End

    Context 'when value is <TAB><TAB>abc'
      set_value() { value="${TAB}${TAB}abc"; }
      It 'trims left tab'
        When call shellspec_trim value
        The value "$value" should eq 'abc'
      End
    End
  End

  Describe "shellspec_replace()"
    Context 'when value is "a==b==c"'
      Before 'value="a==b==c"'
      It 'replaces string'
        When call shellspec_replace value "==" "--"
        The variable value should eq "a--b--c"
      End
    End

    Context 'when value is "a*b*c"'
      Before 'value="a*b*c"'
      It 'replaces string'
        When call shellspec_replace value "*" "-"
        The variable value should eq "a-b-c"
      End
    End

    Context 'when value is "a b c"'
      Before 'value="a b c"'
      It 'replaces string'
        When call shellspec_replace value " " "-"
        The variable value should eq "a-b-c"
      End
    End

    Context 'when value is "a/b/c"'
      Before 'value="a/b/c"'
      It 'replaces string'
        When call shellspec_replace value "/" "-"
        The variable value should eq "a-b-c"
      End
    End

    Context 'when value is "a-b-c"'
      Before 'value="a-b-c"'
      It 'replaces string'
        When call shellspec_replace value "-" "--"
        The variable value should eq "a--b--c"
      End
    End
  End
End
