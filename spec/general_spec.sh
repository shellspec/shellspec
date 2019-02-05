#shellcheck shell=sh disable=SC2016

Describe "general.sh"
  Describe 'shellspec_reset_params()'
    reset_params() {
      shellspec_reset_params "$1" "$2"
      eval "$SHELLSPEC_RESET_PARAMS"
      printf '%s\n' "$@"
    }

    Example "separate by '"
      When call reset_params '$3' "'" "a'b'c"
      The first  line of stdout should equal 'a'
      The second line of stdout should equal 'b'
      The third  line of stdout should equal 'c'
    End

    Example 'separate by : fourth args only'
      When call reset_params '"$3" $4' : "1:2:3" "a:b:c"
      The stdout line 1 should equal '1:2:3'
      The stdout line 2 should end with 'a'
      The stdout line 3 should equal 'b'
      The stdout line 4 should equal 'c'
    End
  End

  Describe 'shellspec_splice_params()'
    set_params() { params="a b c d e f g"; }
    Before set_params

    splice() {
      args=$*
      eval "set -- $params"
      eval "shellspec_splice_params $# $args"
      eval "$SHELLSPEC_RESET_PARAMS"
      echo "${*:-}"
    }

    Example 'remove all parameters after offset 0'
      When call splice 0
      The stdout should equal ""
    End

    Example 'remove all parameters after offset 2'
      When call splice 2
      The stdout should equal 'a b'
    End

    Example 'remove 2 parameters after offset 3'
      When call splice 3 2
      The stdout should equal 'a b c f g'
    End

    Example 'remove 2 parameters after offset 3, and insert list'
      Set a=A b=B c=C
      When call splice 3 2 a b c
      The stdout should equal 'a b c A B C f g'
    End
  End

  Describe 'shellspec_each()'
    callback() { echo "$1:$2:$3"; }

    Example 'call callback with index and value'
      When call shellspec_each callback a b c
      The stdout should equal "a:1:3${SHELLSPEC_LF}b:2:3${SHELLSPEC_LF}c:3:3"
    End

    Example 'call callback with no params'
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

    Example 'call callback with index and value'
      When call _find a1 b1 c1 a2 b2 c2 a3 b3 c3
      The stdout should equal "a1 a2 a3"
    End
  End

  Describe 'shellspec_sequence()'
    callback() { shellspec_puts "$1,"; }

    Example 'calling with "1 to 5" returns 1, 2, 3, 4, 5'
      When call shellspec_sequence callback 1 5
      The stdout should equal "1,2,3,4,5,"
    End

    Example 'calling with "1 to 5 step 2" returns 1, 3, 5'
      When call shellspec_sequence callback 1 5 2
      The stdout should equal "1,3,5,"
    End

    Example 'calling with "5 to 1" returns 5, 4, 3, 2, 1'
      When call shellspec_sequence callback 5 1
      The stdout should equal "5,4,3,2,1,"
    End
  End

  Describe 'shellspec_puts()'
    Example 'shellspec_puts no outputs to stdout'
      When call shellspec_puts
      The entire stdout should equal ''
    End

    Example 'shellspec_puts outputs to stdout'
      When call shellspec_puts 'a'
      The entire stdout should equal 'a'
    End

    Example 'shellspec_puts joins by space and outputs arguments'
      When call shellspec_puts 'a' 'b'
      The entire stdout should equal 'a b'
    End

    Example 'shellspec_puts outputs with raw'
      When call shellspec_puts 'a\b'
      The entire stdout should equal 'a\b'
      The length of entire stdout should equal 3
    End

    Example 'shellspec_puts outputs -n'
      When call shellspec_puts -n
      The entire stdout should equal '-n'
    End
  End

  Describe 'putsn()'
    Example 'shellspec_putsn no outputs to stdout'
      When call shellspec_putsn
      The entire stdout should equal "${SHELLSPEC_LF}"
    End

    Example 'shellspec_putsn outputs to stdout append with LF'
      When call shellspec_putsn "a"
      The entire stdout should equal "a${SHELLSPEC_LF}"
    End

    Example 'shellspec_putsn joins by space and outputs arguments append with LF'
      When call shellspec_putsn "a" "b"
      The entire stdout should equal "a b${SHELLSPEC_LF}"
    End

    Example 'shellspec_putsn outputs with raw append with LF'
      When call shellspec_putsn 'a\b'
      The entire stdout should equal "a\\b${SHELLSPEC_LF}"
      The length of entire stdout should equal 4
    End
  End

  Describe 'shellspec_escape_quote()'
    example() {
      var=$1
      shellspec_escape_quote var
      eval "ret='$var'"
    }

    Example 'escaped string is evaluatable by eval'
      When call example "te'st"
      The variable ret should equal "te'st"
    End
  End

  Describe "shellspec_padding()"
    Example "padding with @"
      When call shellspec_padding str "@" 10
      The variable str should equal '@@@@@@@@@@'
    End
  End

  Describe "shellspec_includes()"
    Example "return success if includes value"
      When call shellspec_includes "abc" "b"
      The status should be success
    End

    Example "return failure if not includes value"
      When call shellspec_includes "abc" "d"
      The status should be failure
    End

    Example "treats | as not meta character"
      When call shellspec_includes "a|b|c" "|b|"
      The status should be success
    End

    Example "treats * as not meta character"
      When call shellspec_includes "abc" "*"
      The status should be failure
    End

    Example "treats ? as not meta character"
      When call shellspec_includes "abc" "?"
      The status should be failure
    End

    Example "treats [] as not meta character"
      When call shellspec_includes "abc[d]" "c[d]"
      The status should be success
    End

    Example "treats \" as not meta character"
      When call shellspec_includes "a\"c" '"'
      The status should be success
    End
  End
End
