#shellcheck shell=sh disable=SC2016

% FIXTURE: "$SHELLSPEC_SPECDIR/fixture"

Describe "general.sh"
  Describe 'shellspec_shell_info()'
    Before SHELLSPEC_SHELL_TYPE="" SHELLSPEC_SHELL_VERSION=""
    pretend() {
      eval "
        shellspec_shell_version() {
          [ \"\$1\" = \"$1\" ] || return 1
          SHELLSPEC_SHELL_TYPE=\"$1\" SHELLSPEC_SHELL_VERSION=\"$2\"
        }
      "
    }

    Context '${.sh.version} not available'
      Before SHELLSPEC_SH_VERSION=''

      Context 'pretend to be bash'
        Before 'pretend bash "4.4.19(1)-release"'
        It 'detects as bash'
          When call shellspec_shell_info
          The variable SHELLSPEC_SHELL_TYPE should eq 'bash'
        End
      End

      Context 'pretend to be zsh'
        Before 'pretend zsh "5.4.2"'
        It 'detects as zsh'
          When call shellspec_shell_info
          The variable SHELLSPEC_SHELL_TYPE should eq 'zsh'
        End
      End

      Context 'pretend to be yash'
        Before 'pretend yash "2.46"'
        It 'detects as yash'
          When call shellspec_shell_info
          The variable SHELLSPEC_SHELL_TYPE should eq 'yash'
        End
      End

      Context 'pretend to be posh'
        Before 'pretend posh "0.13.1"'
        It 'detects as yash'
          When call shellspec_shell_info
          The variable SHELLSPEC_SHELL_TYPE should eq 'posh'
        End
      End

      Context 'pretend to be mksh'
        Before 'pretend ksh "@(#)MIRBSD KSH R56 2018/01/14"'
        It 'detects as mksh'
          When call shellspec_shell_info
          The variable SHELLSPEC_SHELL_TYPE should eq 'mksh'
        End
      End

      Context 'pretend to be pdksh'
        Before 'pretend ksh "@(#)PD KSH v5.2.14 99/07/13.2"'
        It 'detects as pdksh'
          When call shellspec_shell_info
          The variable SHELLSPEC_SHELL_TYPE should eq 'pdksh'
        End
      End

      Context 'pretend to be sh'
        Before 'pretend "" ""'
        It 'detects as sh'
          When call shellspec_shell_info
          The variable SHELLSPEC_SHELL_TYPE should eq 'sh'
        End
      End

      Context 'pretend to be ksh'
        Before 'pretend ksh "ksh Version AJM 93u+ 2012-08-01"'
        It 'detects as ksh'
          When call shellspec_shell_info
          The variable SHELLSPEC_SHELL_TYPE should eq 'ksh'
        End
      End
    End

    Context '${.sh.version} not available'
      Context 'pretend to be old ksh'
        Before 'SHELLSPEC_SH_VERSION="Version M 1993-12-28 q"'
        Before 'pretend sh ""'
        It 'detects as ksh'
          When call shellspec_shell_info
          The variable SHELLSPEC_SHELL_TYPE should eq 'ksh'
        End
      End

      Context 'pretend to be bosh'
        Before 'SHELLSPEC_SH_VERSION="bosh version bosh 2019/02/05 a+"'
        Before 'pretend sh ""'
        It 'detects as bosh'
          When call shellspec_shell_info
          The variable SHELLSPEC_SHELL_TYPE should eq 'bosh'
        End
      End

      Context 'pretend to be posh'
        Before 'SHELLSPEC_SH_VERSION="pbosh version pbosh 2019/02/05 a+"'
        Before 'pretend sh ""'
        It 'detects as pbosh'
          When call shellspec_shell_info
          The variable SHELLSPEC_SHELL_TYPE should eq 'pbosh'
        End
      End
    End
  End

  Describe 'shellspec_shell_version()'
    Before 'MYSH_VERSION="1.0" SHELLSPEC_SH_VERSION=""'

    It 'returns success when shell detection is successful.'
      When call shellspec_shell_version mysh MYSH_VERSION
      The status should be success
      The variable SHELLSPEC_SHELL_TYPE should eq mysh
      The variable SHELLSPEC_SHELL_VERSION should eq '1.0'
    End

    It 'returns failure when shell detection is not successful.'
      When call shellspec_shell_version nosh NOSH_VERSION
      The status should be failure
      The variable SHELLSPEC_SHELL_TYPE should eq 'sh'
      The variable SHELLSPEC_SHELL_VERSION should eq ''
    End
  End

  Describe 'shellspec_import()'
    It 'exits when module not found'
      When run shellspec_import not-found-module
      The status should be failure
      The stderr should be defined
    End

    It 'outputs error message to stderr'
      When run shellspec_import not-found-module
      The status should be defined
      The stderr should be present
    End
  End

  Describe 'shellspec_find_files()'
    found() { echo "${1#"$FIXTURE/files/"}"; }
    It "finds files"
      When call shellspec_find_files found "$FIXTURE/files"
      The output should include "file1"
      The output should include "file2"
      The output should include "dir1-file"
      The output should include "dir1-dir2-file"
      The lines of output should eq 4
    End
  End

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
    Before 'a=A b=B c=C'

    splice() {
      eval "set -- $1; shellspec_splice_params \$# $2"
      eval "$SHELLSPEC_RESET_PARAMS"
      eval echo ${1+'"$@"'}
    }

    It 'removes all parameters when specified offset 0'
      When call splice "a b c d e f g" 0
      The stdout should equal ""
    End

    It 'Leave all parameters when offset is more than the count of parametes'
      When call splice "a b c d e f g" "7"
      The stdout should equal 'a b c d e f g'
    End

    It 'removes all parameters after specified offset'
      When call splice "a b c d e f g" "2"
      The stdout should equal 'a b'
    End

    It 'removes the specified number of parameters from the offset'
      When call splice "a b c d e f g" "3 2"
      The stdout should equal 'a b c f g'
    End

    It 'inserts list where removed position'
      When call splice "a b c d e f g" "3 2 a b c"
      The stdout should equal 'a b c A B C f g'
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
      echo "$@"
    }

    It 'calls callback with index and value'
      When call _find a1 b1 c1 a2 b2 c2 a3 b3 c3
      The stdout should equal "a1 a2 a3"
    End
  End

  Describe 'shellspec_sequence()'
    callback() { %- "$1,"; }

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

  Describe 'shellspec_loop()'
    callback() { %- "called "; }

    It 'calls callback specified times'
      When call shellspec_loop callback 3
      The output should eq "called called called "
    End
  End

  Describe 'shellspec_escape_quote()'
    prepare() { var="te'st"; }
    decode() { eval "ret='$var'"; }

    It 'returns escaped string that evaluatable by eval'
      BeforeCall prepare
      AfterCall decode
      When call shellspec_escape_quote var
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

  Describe 'shellspec_readfile()'
    It 'reads the file as is'
      When call shellspec_readfile var "$FIXTURE/end-with-multiple-lf.txt"
      The variable var should equal "a${LF}${LF}"
    End
  End

  Describe "shellspec_trim()"
    It 'trims space'
      When call shellspec_trim value "  abc  "
      The value "$value" should eq 'abc'
    End

    It 'trims tab'
      When call shellspec_trim value "${TAB}${TAB}abc${TAB}${TAB}"
      The value "$value" should eq 'abc'
    End
  End

  Describe "shellspec_replace()"
    replace() {
      chars="$1"
      while [ "$chars" ]; do
        ch=${chars%"${chars#?}"} && chars=${chars#?}
        value="a${ch}${ch}${ch}b${ch}${ch}${ch}c"
        real_replace value "$ch" "x"
        [ "$value" = "axxxbxxxc" ] || echo "$ch"
      done
    }

    Describe "fast version"
      real_replace() { shellspec_replace "$@"; }
      It 'replaces various characters'
        When call replace '!"#$%&()-=^~\|@`[{;+:*]}.>/?_ '"'"
        The output should eq ''
      End
    End

    Describe "posix version"
      Skip if 'it is old posh with bugs' posh_pattern_matching_bug
      real_replace() { shellspec_replace_posix "$@"; }
      It 'replaces various characters'
        When call replace '!"#$%&()-=^~\|@`[{;+:*]}.>/?_ '"'"
        The output should eq ''
      End
    End
  End

  Describe "shellspec_match()"
    It 'returns success if value mactches with pattern'
      When call shellspec_match foo "[fF]?*"
      The status should be success
    End

    It 'returns failure if value mactches with pattern'
      When call shellspec_match bar "[fF]?*"
      The status should be failure
    End
  End

  Describe "shellspec_join()"
    Before value=''
    It 'joins arguments by space'
      When call shellspec_join value foo bar baz
      The variable value should eq 'foo bar baz'
    End

    Context 'when IFS is @'
      Before IFS='@'
      It 'joins arguments by space'
        When call shellspec_join value foo bar baz
        The variable value should eq 'foo bar baz'
      End
    End
  End

  Describe "shellspec_shift10()"
    Context 'integer number'
      It "shifts to left"
        When call shellspec_shift10 ret 123 2
        The variable ret should eq 12300
      End

      It "shifts to right less then length"
        When call shellspec_shift10 ret 123 -2
        The variable ret should eq 1.23
      End

      It "shifts to right more than length"
        When call shellspec_shift10 ret 123 -4
        The variable ret should eq 0.0123
      End
    End

    Context 'number with decimal part'
      It "shifts to left less than the fraction length"
        When call shellspec_shift10 ret 123.456 2
        The variable ret should eq 12345.6
      End

      It "shifts to left the fraction length"
        When call shellspec_shift10 ret 123.4 1
        The variable ret should eq 1234
      End

      It "shifts to left more than the fraction length"
        When call shellspec_shift10 ret 123.4 2
        The variable ret should eq 12340
      End

      It "shifts to right turn"
        When call shellspec_shift10 ret 123.456 -2
        The variable ret should eq 1.23456
      End
    End
  End

  Describe "shellspec_chomp()"
    Before 'var="string${LF}${LF}${LF}"'
    It "removes trailing LF"
      When call shellspec_chomp var
      The variable var should eq "string"
    End
  End
End
