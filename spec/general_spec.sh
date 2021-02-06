#shellcheck shell=sh disable=SC2016

% BIN: "$SHELLSPEC_HELPERDIR/fixture/bin"
% FIXTURE: "$SHELLSPEC_HELPERDIR/fixture"
% EMPTY_FILE: "$SHELLSPEC_HELPERDIR/fixture/empty"
% NON_EMPTY_FILE: "$SHELLSPEC_HELPERDIR/fixture/file"

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
    Before 'SHELLSPEC_LOAD_PATH=$FIXTURE'

    It 'exits when module not found'
      When run shellspec_import not-found-module
      The status should be failure
      The stderr should include "not-found-module"
    End

    It 'imports module'
      When run shellspec_import "source"
      The status should be success
      The stdout should be blank
    End

    It 'imports module with arguments'
      When run shellspec_import "source" a b c
      The status should be success
      The stdout should eq "a:b:c"
    End
  End

  Describe 'shellspec_resolve_module_path()'
    Before 'SHELLSPEC_LOAD_PATH=$FIXTURE'

    It 'exits when module not found'
      When run shellspec_resolve_module_path module_path not-found-module
      The status should be failure
      The stderr should include "not-found-module"
    End

    It 'resolve module path'
      When call shellspec_resolve_module_path module_path "source"
      The variable module_path should eq "$FIXTURE/source.sh"
    End
  End

  Describe 'shellspec_module_exists()'
    Before 'SHELLSPEC_LOAD_PATH=$FIXTURE'

    Parameters
      + "not-found-module"  failure
      + "source"            success
    End

    It "checks the existence of the module"
      When run shellspec_module_exists "$2"
      The status should be "$3"
    End
  End

  Describe 'shellspec_source()'
    It 'sources file'
      When run shellspec_source "$FIXTURE/source.sh"
      The status should be success
      The stdout should be blank
    End

    It 'sources file with arguments'
      When run shellspec_source "$FIXTURE/source.sh" a b c
      The status should be success
      The stdout should eq "a:b:c"
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

  Describe 'shellspec_printf()'
    It 'call printf builtin'
      When call shellspec_printf '%03d' 1
      The stdout should equal '001'
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

  Describe 'shellspec_get_line()'
    lf="$SHELLSPEC_LF"

    Parameters
      1 ""                be undefined    ''
      1 "${lf}"           eq ""           '${lf}'
      2 "${lf}"           be undefined    '${lf}'
      1 "a"               eq "a"          'a'
      2 "a"               be undefined    'a'
      2 "1${lf}2${lf}3"   eq 2            '1${lf}2${lf}3'
      2 "1${lf}${lf}3"    eq ""           '1${lf}${lf}3'
      2 "1${lf}${lf}"     eq ""           '1${lf}${lf}'
      3 "1${lf}${lf}"     be undefined    '1${lf}${lf}'
    End

    It "gets the specified line (line $1 of \"$5\")"
      When call shellspec_get_line ret "$1" "$2"
      The variable ret should "$3" "$4"
    End
  End

  Describe 'shellspec_count_lines()'
    lf="$SHELLSPEC_LF"

    Parameters
      ""                0 ''
      "${lf}"           1 '${lf}'
      "a"               1 'a'
      "1${lf}2${lf}3"   3 '1${lf}2${lf}3'
      "1${lf}${lf}3"    3 '1${lf}${lf}3'
      "1${lf}${lf}"     2 '1${lf}${lf}'
    End

    It "counts the number of lines ($3)"
      When call shellspec_count_lines ret "$1"
      The variable ret should eq "$2"
    End
  End

  Describe "shellspec_padding()"
    It "paddings with @"
      When call shellspec_padding str "@" 10
      The variable str should equal '@@@@@@@@@@'
    End
  End

  Describe "shellspec_wrap()"
    lf="$SHELLSPEC_LF"

    Parameters
      "line1${lf}line2"       "[[line1]]${lf}[[line2]]"
      "line1${lf}line2${lf}"  "[[line1]]${lf}[[line2]]${lf}"
    End

    It "wraps each line"
      When call shellspec_wrap ret "$1" "[[" "]]"
      The variable ret should equal "$2"
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

  Describe "shellspec_replace_all_multiline()"
    Before setup
    Context "when does not end a with newline"
      setup() {
        # shellcheck disable=SC2034
        text=$(printf '%s@\n' foo bar baz)
      }
      It "replaces multiple lines"
        When call shellspec_replace_all_multiline text "@" "%"
        The line 1 of variable text should eq "foo%"
        The line 2 of variable text should eq "bar%"
        The line 3 of variable text should eq "baz%"
        The line 4 of variable text should be undefined
      End
    End

    Context "when end with a newline"
      setup() {
        # shellcheck disable=SC2034
        text="$(printf '%s@\n' foo bar baz)${SHELLSPEC_LF}${SHELLSPEC_LF}"
      }
      It "replaces multiple lines"
        When call shellspec_replace_all_multiline text "@" "%"
        The line 1 of variable text should eq "foo%"
        The line 2 of variable text should eq "bar%"
        The line 3 of variable text should eq "baz%"
        The line 4 of variable text should eq ""
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

  Describe 'shellspec_pack()'
    _pack() {
      shellspec_pack "$@"
      eval "set -- $var"
      if [ $# -gt 0 ]; then
        %printf '%s\n' "$@"
      fi
    }

    It 'pack the empty arguments into one variable'
      When call _pack var
      The variable var should equal ""
    End

    It 'pack the arguments into one variable'
      When call _pack var "a" "a b" "a'b"
      The line 1 should equal "a"
      The line 2 should equal "a b"
      The line 3 should equal "a'b"
    End
  End

  Describe 'shellspec_readfile()'
    Before var=dummy

    It 'reads the file as is'
      When call shellspec_readfile var "$FIXTURE/end-with-multiple-lf.txt"
      The variable var should equal "a${SHELLSPEC_LF}${SHELLSPEC_LF}"
    End

    It 'reads the file as is'
      When call shellspec_readfile var "$FIXTURE/end-without-lf.txt"
      The variable var should equal "foo\\${SHELLSPEC_LF}bar"
    End

    It 'unsets the variable when the file does not exist'
      When call shellspec_readfile var "$FIXTURE/no-such-a-file.txt"
      The variable var should be undefined
    End
  End

  Describe 'shellspec_readfile_once()'
    mock() {
      shellspec_readfile() { echo "readfile" "$@"; }
    }
    BeforeRun mock

    Context "when the variable is undefined"
      Before "unset var ||:"
      It 'reads the file'
        When run shellspec_readfile_once var "file"
        The output should eq "readfile var file"
      End
    End

    Context "when the variable is defined"
      Before "var=''"
      It 'does not read the file'
        When run shellspec_readfile_once var "file"
        The output should be blank
      End
    End
  End

  Describe 'shellspec_capturefile()'
    It 'reads the file without trailing LF'
      When call shellspec_capturefile var "$FIXTURE/end-with-multiple-lf.txt"
      The variable var should equal "a"
    End

    It 'reads the file as is'
      When call shellspec_capturefile var "$FIXTURE/end-without-lf.txt"
      The variable var should equal "foo\\${SHELLSPEC_LF}bar"
    End
  End

  Describe 'shellspec_head()'
    Data
      #|line1
      #|line2
      #|line3
      #|line4
      #|line5
    End

    Parameters
      4 4 "line4" 5 eq "..."
      5 5 "line5" 6 be undefined
      6 5 "line5" 6 be undefined
    End

    It 'reads the specified number of lines'
      When call shellspec_head var "$1"
      The line "$2" of variable var should eq "$3"
      The line "$4" of variable var should "$5" "$6"
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

  Describe "shellspec_unsetf()"
    Context 'when POSIX-compliant function name'
      It "unsets fcuntion (not defined)"
        When call shellspec_unsetf "no_such_a_function"
        The status should be success
      End

      unsetf() {
        unsetf_test() { :; }
        shellspec_unsetf unsetf_test
        unsetf_test
      }

      It "unsets defined fcuntion"
        When call unsetf
        The status should be failure
        The error should be defined
      End
    End

    Context 'when not POSIX-compliant function name'
      It "unsets fcuntion (not defined)"
        When call shellspec_unsetf "no-such-a-function"
        The status should be success
      End

      shellspec_is_function() { return 1; }

      unsetf() {
        unsetf_test() { :; }
        shellspec_unsetf unsetf_test
        unsetf_test
      }

      It "unsets defined fcuntion"
        When call unsetf
        The status should be failure
        The error should be defined
      End
    End
  End

  Describe 'shellspec_exportp()'
    It 'lists exported environment variables'
      When call shellspec_exportp
      The output should be defined
      The error should be blank
    End
  End

  Describe 'shellspec_list_envkeys()'
    callback() { echo "$1"; }

    Context "when posix format"
      shellspec_exportp() { %text
        #|export VAR1
        #|export VAR2='10'
        #|export VAR3='foo
        #|export NOVAR'
        #|export -i10 VAR4=2
      }
      It 'lists environment variable names'
        When call shellspec_list_envkeys callback
        The line 1 should eq "VAR1"
        The line 2 should eq "VAR2"
        The line 3 should eq "VAR3"
        The line 4 should not eq "NOVAR"
        The line 4 should eq "VAR4" # zsh only
      End
    End

    Context "when bash format"
      shellspec_exportp() { %text
        #|declare -x VAR1
        #|declare -ix VAR2='10'
        #|declare -x VAR3='foo
        #|declare -x NOVAR'
        #|declare -i -x -L 10 VAR4
        #|declare -i -x -L 10 VAR5='10'
      }
      It 'lists environment variable names'
        When call shellspec_list_envkeys callback
        The line 1 should eq "VAR1"
        The line 2 should eq "VAR2"
        The line 3 should eq "VAR3"
        The line 4 should not eq "NOVAR"
        The line 4 should eq "VAR4" # Invalid bash format, but supported
        The line 5 should eq "VAR5" # Invalid bash format, but supported
      End
    End

    Context "when posh format"
      shellspec_exportp() { %text
        #|VAR1
      }
      It 'lists environment variable names'
        When call shellspec_list_envkeys callback
        The line 1 should eq "VAR1"
      End
    End

    It 'stops when the callback returns non-zero'
      shellspec_exportp() { %text
        #|export VAR1
        #|export VAR2='10'
      }
      callback() { echo "$1"; return 2; }
      When call shellspec_list_envkeys callback
      The output should eq "VAR1"
      The status should eq 2
    End

    Describe 'shellspec_list_envkeys_sanitize()'
      It 'sanitizes meta characters'
        When call shellspec_list_envkeys_sanitize line '!#&()*;<>?[]`{|}~'
        The variable line should eq '_________________'
      End

      It 'leaves these character as is'
        When call shellspec_list_envkeys_sanitize line "\"\$%'+,-./:@\\^_="
        The variable line should eq "\"\$%'+,-./:@\\^_="
      End
    End
  End

  Describe 'shellspec_exists_envkey()'
    shellspec_exportp() { %text
      #|export VAR1
    }

    Parameters
      VAR1 success
      VAR2 failure
    End

    It 'checks environment variable name exists'
      When call shellspec_exists_envkey "$1"
      The status should be "$2"
    End
  End

  Describe 'shellspec_is_readonly()'
    Skip if "readonly malfunction" readonly_malfunction

    Parameters
      A success
      B failure
      C failure
    End

    # shellcheck disable=SC2034
    _readonly() {
      A=1 B=1 C=1
      readonly A
      unset C
      shellspec_is_readonly "$@"
    }

    It 'checks that the variable is read only'
      When call _readonly "$1"
      The status should be "$2"
    End
  End

  Describe "shellspec_abspath_unix()"
    Parameters
      "/"               "/"                   "/"
      "/"               ""                    "/"
      "/"               "a"                   "/a"
      "/foo/bar"        ""                    "/foo/bar"
      "/foo/bar/"       ""                    "/foo/bar"
      "/foo/bar/"       "/"                   "/"
      "/foo/bar/"       "/"                   "/"
      "/foo/bar"        "../a"                "/foo/a"
      "/foo/bar"        "../../../../../a"    "/a"
      "/foo/bar"        "../../../a/../b"     "/b"
      "/foo/bar"        "./a/b"               "/foo/bar/a/b"
      "/foo/bar"        "a///b//c"            "/foo/bar/a/b/c"
      "/foo/bar"        "/a/"                 "/a"
      "/foo/bar"        "//a"                 "/a"
    End

    It "converts to absolute path ($1 + $2 => $3)"
      When call shellspec_abspath_unix ret "$2" "$1"
      The variable ret should eq "$3"
    End
  End

  Describe "shellspec_abspath_win()"
    Parameters
      'dummy'     '//WSL$/ubuntu' '//WSL$/ubuntu'
      'dummy'     'D:/path'       'D:/path'
      'D:/temp'   'D:path'        'D:/temp/path'
      'D:/'       'D:path'        'D:/path'
      'D:/temp'   '/path'         'D:/path'
      'D:/temp'   'path'          'D:/temp/path'
      'D:/'       'path'          'D:/path'
    End

    shellspec_chdrv() { :; }

    It "converts to absolute path ($1 + $2 => $3)"
      When call shellspec_abspath_win ret "$2" "$1"
      The variable ret should eq "$3"
    End
  End
End
