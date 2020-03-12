#shellcheck shell=sh disable=SC2016

% FIXTURE: "$SHELLSPEC_SPECDIR/fixture"
% EMPTY_FILE: "$SHELLSPEC_SPECDIR/fixture/empty"
% NON_EMPTY_FILE: "$SHELLSPEC_SPECDIR/fixture/file"

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

    Context '${.sh.version} not available shell'
      Before SHELLSPEC_SH_VERSION=''

      Parameters
        bash  bash "4.4.19(1)-release"
        zsh   zsh  "5.4.2"
        yash  yash "2.46"
        posh  posh "0.13.1"
        mksh  ksh  "@(#)MIRBSD KSH R56 2018/01/14"
        pdksh ksh  "@(#)PD KSH v5.2.14 99/07/13.2"
        ksh   ksh "ksh Version AJM 93u+ 2012-08-01"
        sh    ""    ""
      End

      It "detects as $1"
        BeforeCall "pretend '$2' '$3'"
        When call shellspec_shell_info
        The variable SHELLSPEC_SHELL_TYPE should eq "$1"
      End
    End

    Context '${.sh.version} available shell'
      Parameters
        ksh   "Version M 1993-12-28 q"
        bosh  "bosh version bosh 2019/02/05 a+"
        pbosh "pbosh version pbosh 2019/02/05 a+"
      End

      It "detects as $1"
        BeforeCall "SHELLSPEC_SH_VERSION='$2'"
        BeforeCall 'pretend sh ""'
        When call shellspec_shell_info
        The variable SHELLSPEC_SHELL_TYPE should eq "$1"
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
      The stderr should include "not-found-module"
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
      The line 1 of stdout should equal "a:1:3"
      The line 2 of stdout should equal "b:2:3"
      The line 3 of stdout should equal "c:3:3"
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
      The entire stdout should equal "${IFS%?}"
    End

    It 'outputs append with LF'
      When call shellspec_putsn "a"
      The entire stdout should equal "a${IFS%?}"
    End

    It 'joins arguments with space and outputs append with LF'
      When call shellspec_putsn "a" "b"
      The entire stdout should equal "a b${IFS%?}"
    End

    It 'outputs with raw string append with LF'
      When call shellspec_putsn 'a\b'
      The entire stdout should equal "a\\b${IFS%?}"
      The length of entire stdout should equal 4
    End

    Context 'when change IFS'
      It 'joins arguments with spaces'
        BeforeRun 'IFS=@'
        When run shellspec_putsn a b c
        The entire stdout should equal "a b c${IFS%?}"
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
      When call shellspec_lines callback "a${IFS%?}b"
      The stdout should eq "1:a 2:b "
    End

    It 'ignores last LF'
      When call shellspec_lines callback "a${IFS%?}b${IFS%?}"
      The stdout should eq "1:a 2:b "
    End

    It 'can cancels calls of callback.'
      When call shellspec_lines callback_with_cancel "a${IFS%?}b"
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
      The variable var should equal "a${IFS%?}${IFS%?}"
    End
  End

  Describe "shellspec_trim()"
    It 'trims white space'
      When call shellspec_trim value " $IFS abc $IFS "
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

  Describe "shellspec_ends_with_backslash()"
    It 'returns success if ends with backslash'
      When call shellspec_ends_with_backslash "foo\\"
      The status should be success
    End

    It 'returns failure if ends with backslash'
      When call shellspec_ends_with_backslash 'foo'
      The status should be failure
    End
  End

  Describe "shellspec_match() (deprecated)"
    It 'returns success if value mactches with pattern'
      When call shellspec_match foo "[fF]?*"
      The status should be success
    End

    It 'returns failure if value mactches with pattern'
      When call shellspec_match bar "[fF]?*"
      The status should be failure
    End
  End

  Describe "shellspec_match_pattern()"
    It 'can use shell script pattern'
      When call shellspec_match_pattern foobar "[fF]??b*"
      The status should be success
    End

    It 'can use negative pattern'
      When call shellspec_match_pattern foobar "[!fF]??b*"
      The status should be failure
    End

    It 'can use OR'
      When call shellspec_match_pattern foo "foo|bar"
      The status should be success
    End

    It 'escapes symbol internally to avoid syntax error'
      string() { echo "!\"#\$%&'()-=^~\\@\`{;+:},<.>/\_"; }
      When call shellspec_match_pattern "$(string)" "$(string)"
      The status should be success
    End

    It 'escapes spaces internally to avoid syntax error'
      # Do not modify this string
      string() { printf "= \b = \f = \n = \r = \t = \v = "; }
      When call shellspec_match_pattern "$(string)" "$(string)"
      The status should be success
    End
  End

  Describe "shellspec_escape_pattern()"
    check() {
      [ $# -eq 1 ] && set -- "$1" "$1"
      pattern=$1
      shellspec_escape_pattern pattern
      eval "case \"\$2\" in ($pattern) true ;; (*) false ;; esac &&:"
    }

    It 'escapes pattern metacharacters'
      When call check "!\"#\$%&'()-=^~\\@\`{;+:},<.>/\_"
      The status should be success
    End

    Describe "pattern metacharacters"
      Parameters
         "*" "a*"
         "??" "a?"
         "[a]" "a"
         "a|b" "a"
      End

      It "should be match ($1 = $1)"
        When call check "$1"
        The status should be success
      End

      It "should not be match ($1 != $2)"
        When call check "$1" "$2"
        The status should be failure
      End
    End
  End

  Describe "shellspec_join()"
    Context "when no arguments"
      It 'returns empty'
        When call shellspec_join value "@"
        The variable value should eq ""
      End
    End

    Context "when one argument"
      It 'returns argument'
        When call shellspec_join value "@" foo
        The variable value should eq "foo"
      End
    End

    Context "when multiple arguments"
      Parameters:value " " "<>" "a" "|"

      It "joins by '$1'"
        When call shellspec_join value "$1" foo bar baz
        The variable value should eq "foo$1bar$1baz"
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
    Before "var='string${IFS%?}${IFS%?}${IFS%?}'"
    It "removes trailing LF"
      When call shellspec_chomp var
      The variable var should eq "string"
    End
  End

  Describe "shellspec_which()"
    Context 'when PATH=/foo:/bin:/bar'
      Before PATH=/foo:/bin:/bar
      It "retrieves found path"
        When call shellspec_which sh
        The output should eq "/bin/sh"
      End
    End

    Context 'when PATH=/foo:/bar'
      Before PATH=/foo:/bar
      It "retrieves nothing"
        When call shellspec_which sh
        The status should eq 1
      End
    End

    Context 'when PATH='
      Before PATH=
      It "retrieves nothing"
        When call shellspec_which sh
        The status should eq 1
      End
    End
  End

  Describe "shellspec_difference_values()"
    Context 'when values is empty'
      Before var=''
      It "removes specified values"
        When call shellspec_difference_values var ":" "@5:@1:@2-2:@1"
        The variable var should eq ""
      End
    End

    Context 'when values is not blank'
      Before var=@1:@2-1:@1:@2-2:@3
      It "removes specified values"
        When call shellspec_difference_values var ":" "@5:@1:@2-2:@1"
        The variable var should eq "@2-1:@3"
      End
    End
  End

  Describe "shellspec_union_values()"
    Context 'when values is empty'
      Before var=''
      It "removes specified values"
        When call shellspec_union_values var ":" "@1-1:@1-2"
        The variable var should eq "@1-1:@1-2"
      End
    End

    Context 'when values is not empty'
      Before var=@1:@2-1:@1:@2-2:@3
      It "removes specified values"
        When call shellspec_union_values var ":" "@1:@2-1:@2-3:@3:@4:@3"
        The variable var should eq "@1:@2-1:@2-2:@3:@2-3:@4"
      End
    End
  End

  Describe "shellspec_is_empty_file()"
    It "returns success if file is empty"
      When call shellspec_is_empty_file "$EMPTY_FILE"
      The status should be success
    End

    It "returns failure if file is not empty"
      When call shellspec_is_empty_file "$NON_EMPTY_FILE"
      The status should be failure
    End

    It "returns failure if file does not exist"
      When call shellspec_is_empty_file "$FIXTURE/not-exists"
      The status should be failure
    End
  End
End
