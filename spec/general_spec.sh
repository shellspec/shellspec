#shellcheck shell=sh disable=SC2016

% BIN: "$SHELLSPEC_SPECDIR/fixture/bin"
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

    Context '*_VERSION available shell'
      Before SHELLSPEC_SH_VERSION=''

      Parameters
        bash  bash "4.4.19(1)-release"
        zsh   zsh  "5.4.2"
        yash  yash "2.46"
        posh  posh "0.13.1"
        lksh  ksh  "@(#)LEGACY KSH R40 2012/07/20 Debian-7"
        mksh  ksh  "@(#)MIRBSD KSH R56 2018/01/14"
        pdksh ksh  "@(#)PD KSH v5.2.14 99/07/13.2"
        ksh   ksh  "ksh Version AJM 93u+ 2012-08-01"
        sh    ""   ""
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

    Context '$SH_VERSION available shell'
      Parameters
        pdksh   "@(#)PD KSH v5.2.14 99/07/13.2"
      End

      It "detects as $1"
        BeforeCall "SHELLSPEC_SH_VERSION='$2'"
        BeforeCall 'pretend sh ""'
        When call shellspec_shell_info
        The variable SHELLSPEC_SHELL_TYPE should eq "$1"
      End
    End

    Context 'NetBSD shell'
      It "detects as sh"
        BeforeCall "SHELLSPEC_SH_VERSION='20181212 BUILD:20200214000628Z'"
        BeforeCall 'pretend sh ""'
        When call shellspec_shell_info
        The variable SHELLSPEC_SHELL_TYPE should eq "sh"
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

  Describe "shellspec_replace_all()"
    It "replaces all characters"
      When call shellspec_replace_all replaced "abcabc" "b" "B"
      The variable replaced should eq "aBcaBc"
    End

    It "replaces all characters in variable"
      BeforeCall replaced=abcabc
      When call shellspec_replace_all replaced "b" "B"
      The variable replaced should eq "aBcaBc"
    End

    Describe "characters"
      Parameters:value '!' '"' '#' '$' '%' '&' '(' ')' '-' '=' '^' '~' '|' " " \
        '@' '`' '[' '{' ';' '+' ':' '*' ']' '}' '.' '<' '>' "\\" '?' '_' "'"
      It "replaces all characters ($1)"
        When call shellspec_replace_all replaced "A$1$1$1B$1$1$1C" "$1" "x"
        The variable replaced should eq "AxxxBxxxC"
      End
    End

    Describe "various patterns"
      lf=$SHELLSPEC_LF

      Parameters
        "abcdeabcde"          "cd"    "CD"  "abCDeabCDe"
        "abc[*]abc[*]"        "[*]"   "OK"  "abcOKabcOK"
        "=   ="               " "     "OK"  "=OKOKOK="
        "=${lf}${lf}${lf}="   "$lf"   "OK"  "=OKOKOK="
        '=\='                 "\\"    "OK"  "=OK="
        "\\"                  "\\"    "OK"  "OK"
        '!'                   '!'     "!"   "!"
      End

      It "replaces all strings (string: $2)"
        When call shellspec_replace_all replaced "$1" "$2" "$3"
        The variable replaced should eq "$4"
      End
    End
  End

  Describe "shellspec_replace_all_posix()"
    Skip if "parameter expansion is not POSIX compliant" invalid_posix_parameter_expansion

    It "replaces all characters"
      When call shellspec_replace_all_posix replaced "abcabc" "b" "B"
      The variable replaced should eq "aBcaBc"
    End

    It "replaces all characters in variable"
      BeforeCall replaced=abcabc
      When call shellspec_replace_all_posix replaced "b" "B"
      The variable replaced should eq "aBcaBc"
    End

    Describe "characters"
      Parameters:value '!' '"' '#' '$' '%' '&' '(' ')' '-' '=' '^' '~' '|' " " \
        '@' '`' '[' '{' ';' '+' ':' '*' ']' '}' '.' '<' '>' "\\" '?' '_' "'"
      It "replaces all characters ($1)"
        When call shellspec_replace_all_posix replaced "A$1$1$1B$1$1$1C" "$1" "x"
        The variable replaced should eq "AxxxBxxxC"
      End
    End

    Describe "various patterns"
      lf=$SHELLSPEC_LF

      Parameters
        "abcdeabcde"          "cd"    "CD"  "abCDeabCDe"
        "abc[*]abc[*]"        "[*]"   "OK"  "abcOKabcOK"
        "=   ="               " "     "OK"  "=OKOKOK="
        "=${lf}${lf}${lf}="   "$lf"   "OK"  "=OKOKOK="
        '=\='                 "\\"    "OK"  "=OK="
        "\\"                  "\\"    "OK"  "OK"
        '!'                   '!'     "!"   "!"
      End

      It "replaces all strings (string: $2)"
        When call shellspec_replace_all_posix replaced "$1" "$2" "$3"
        The variable replaced should eq "$4"
      End
    End
  End

  Describe "shellspec_replace_all_fallback()"
    It "replaces all characters"
      When call shellspec_replace_all_fallback replaced "abcabc" "b" "B"
      The variable replaced should eq "aBcaBc"
    End

    It "replaces all characters in variable"
      BeforeCall replaced=abcabc
      When call shellspec_replace_all_fallback replaced "b" "B"
      The variable replaced should eq "aBcaBc"
    End

    Describe "characters"
      Parameters:value '!' '"' '#' '$' '%' '&' '(' ')' '-' '=' '^' '~' '|' " " \
        '@' '`' '[' '{' ';' '+' ':' '*' ']' '}' '.' '<' '>' "\\" '?' '_' "'"
      It "replaces all characters ($1)"
        When call shellspec_replace_all_fallback replaced "A$1$1$1B$1$1$1C" "$1" "x"
        The variable replaced should eq "AxxxBxxxC"
      End
    End

    Describe "various patterns"
      lf=$SHELLSPEC_LF tab=$SHELLSPEC_TAB vt=$SHELLSPEC_VT cr=$SHELLSPEC_CR

      Parameters
        "abcdeabcde"            "cd"    "CD"  "abCDeabCDe"
        "abc[*]abc[*]"          "[*]"   "OK"  "abcOKabcOK"
        "=   ="                 " "     "OK"  "=OKOKOK="
        "=${lf}${lf}${lf}="     "$lf"   "OK"  "=OKOKOK="
        "=${tab}${tab}${tab}="  "$tab"  "OK"  "=OKOKOK="
        "=${vt}${vt}${vt}="     "$vt"   "OK"  "=OKOKOK="
        "=${cr}${cr}${cr}="     "$cr"   "OK"  "=OKOKOK="
        '=\='                   "\\"    "OK"  "=OK="
        "\\"                    "\\"    "OK"  "OK"
        '!'                     '!'     "!"   "!"
        '^'                     '^'     "^"   "^"
      End

      It "replaces all strings (string: $2)"
        When call shellspec_replace_all_fallback replaced "$1" "$2" "$3"
        The variable replaced should eq "$4"
      End
    End
  End

  Describe "shellspec_includes()"
    lf=$SHELLSPEC_LF tab=$SHELLSPEC_TAB vt=$SHELLSPEC_VT cr=$SHELLSPEC_CR

    Parameters
      "abc"               "b"                 success
      "abc"               "d"                 failure
      "a|b|c"             "|b|"               success
      "abc"               "*"                 failure
      "abc"               "?"                 failure
      "abc[d]"            "c[d]"              success
      "# # #"             "# # #"             success
      "a\"\\\$&';\`~"     "a\"\\\$&';\`~"     success
      "< > ( ) { } ^ ="   "< > ( ) { } ^ ="   success
      "$lf$tab$vt$cr"     "$lf$tab$vt$cr"     success
    End

    It "checks if it includes a string (target: $1, string: $2)"
      When call shellspec_includes "$1" "$2"
      The status should be "$3"
    End
  End

  Describe "shellspec_includes_posix()"
    Skip if "parameter expansion is not POSIX compliant" invalid_posix_parameter_expansion
    lf=$SHELLSPEC_LF tab=$SHELLSPEC_TAB vt=$SHELLSPEC_VT cr=$SHELLSPEC_CR

    Parameters
      "abc"               "b"                 success
      "abc"               "d"                 failure
      "a|b|c"             "|b|"               success
      "abc"                "*"                failure
      "abc"               "?"                 failure
      "abc[d]"            "c[d]"              success
      "# # #"             "# # #"             success
      "a\"\\\$&';\`~"     "a\"\\\$&';\`~"     success
      "< > ( ) { } ^ ="   "< > ( ) { } ^ ="   success
      "$lf$tab$vt$cr"     "$lf$tab$vt$cr"     success
    End

    It "checks if it includes a string (target: $1, string: $2)"
      When call shellspec_includes_posix "$1" "$2"
      The status should be "$3"
    End
  End

  Describe "shellspec_includes_fallback()"
    lf=$SHELLSPEC_LF tab=$SHELLSPEC_TAB vt=$SHELLSPEC_VT cr=$SHELLSPEC_CR

    Parameters
      "abc"               "b"                 success
      "abc"               "d"                 failure
      "a|b|c"             "|b|"               success
      "abc"                "*"                failure
      "abc"               "?"                 failure
      "abc[d]"            "c[d]"              success
      "# # #"             "# # #"             success
      "a\"\\\$&';\`~"     "a\"\\\$&';\`~"     success
      "< > ( ) { } ^ ="   "< > ( ) { } ^ ="   success
      "$lf$tab$vt$cr"     "$lf$tab$vt$cr"     success
    End

    It "checks if it includes a string (target: $1, string: $2)"
      When call shellspec_includes_fallback "$1" "$2"
      The status should be "$3"
    End
  End

  Describe "shellspec_starts_with_posix()"
    Skip if "parameter expansion is not POSIX compliant" invalid_posix_parameter_expansion

    Parameters
      "abc"     "a"     success
      "abc"     "d"     failure
      "a|b|c"   "a|"    success
      "abc"      "*"    failure
      "abc"     "?"     failure
      "[a]bcd"  "[a]b"  success
    End

    It "checks if it starts with a string (target: $1, string: $2)"
      When call shellspec_starts_with_posix "$1" "$2"
      The status should be "$3"
    End
  End

  Describe "shellspec_starts_with_fallback()"
    Parameters
      "abc"     "a"     success
      "abc"     "d"     failure
      "a|b|c"   "a|"    success
      "abc"      "*"    failure
      "abc"     "?"     failure
      "[a]bcd"  "[a]b"  success
    End

    It "checks if it starts with a string (target: $1, string: $2)"
      When call shellspec_starts_with_fallback "$1" "$2"
      The status should be "$3"
    End
  End

  Describe "shellspec_ends_with_posix()"
    Skip if "parameter expansion is not POSIX compliant" invalid_posix_parameter_expansion

    Parameters
      "abc"     "c"     success
      "abc"     "d"     failure
      "a|b|c"   "|c"    success
      "abc"      "*"    failure
      "abc"     "?"     failure
      "abc[d]"  "c[d]"  success
    End

    It "checks if it ends with a string (target: $1, string: $2)"
      When call shellspec_ends_with_posix "$1" "$2"
      The status should be "$3"
    End
  End

  Describe "shellspec_ends_with_fallback()"
    Parameters
      "abc"     "c"     success
      "abc"     "d"     failure
      "a|b|c"   "|c"    success
      "abc"      "*"    failure
      "abc"     "?"     failure
      "abc[d]"  "c[d]"  success
    End

    It "checks if it ends with a string (target: $1, string: $2)"
      When call shellspec_ends_with_fallback "$1" "$2"
      The status should be "$3"
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

  Describe 'shellspec_readfile()'
    It 'reads the file as is'
      When call shellspec_readfile var "$FIXTURE/end-with-multiple-lf.txt"
      The variable var should equal "a${IFS%?}${IFS%?}"
    End
  End

  Describe "shellspec_trim()"
    It 'trims white space'
      When call shellspec_trim value " $IFS abc $IFS "
      The variable value should eq 'abc'
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

  Describe 'shellspec_get_nth()'
    It 'fetch nth value seperate by IFS'
      When call shellspec_get_nth var "  a   b c  " 3
      The variable var should equal c
    End

    Parameters
      "a,b,c,d,e"     3 ','   "c"
      "  a  b  c  "   3 ' '   "c"
      ",,a,,"         3 ','   "a"
      "  a   * c  "   2 " "   "*"
    End

    It "fetches nth word ($1 : $2 : $3)" a b
      When call shellspec_get_nth var "$1" "$2" "$3"
      The variable var should equal "$4"
    End
  End

  Describe "shellspec_which()"
    Context 'when command exists'
      It "retrieves found path"
        When call shellspec_which cat
        The output should end with "/cat"
      End
    End

    Context 'when command not exists'
      It "retrieves nothing"
        When call shellspec_which no-such-a-command
        The status should eq 1
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

  Describe "shellspec_pluralize()"
    Before str=''

    It "encloses with prefix and suffix"
      When call shellspec_pluralize str "prefix " "1 example" " suffix"
      The variable str should eq "prefix 1 example suffix"
    End

    Parameters
      " example" ""
      "0 example" "0 examples"
      "1 example" "1 example"
      "2 example" "2 examples"
      "3 fix"     "3 fixes"
    End

    It "pluralizes"
      When call shellspec_pluralize str "$1"
      The variable str should eq "$2"
    End
  End

  Describe "shellspec_exists_file()"
    It "returns success if exists file"
      When call shellspec_exists_file "$EMPTY_FILE"
      The status should be success
    End

    It "returns failure if file does not exist"
      When call shellspec_exists_file "$FIXTURE/not-exists"
      The status should be failure
    End
  End
End
