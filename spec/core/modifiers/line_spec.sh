#shellcheck shell=sh

Describe "core/modifiers/line.sh"
  Describe "line modifier"
    Example 'example'
      The line 1 of value foobarbaz should equal foobarbaz
    End

    Example 'get number of line of subject'
      Set SHELLSPEC_SUBJECT="foo${SHELLSPEC_LF}bar${SHELLSPEC_LF}baz"
      When invoke modifier line 2 _modifier_
      The entire stdout should equal bar
    End

    Example 'last LF should ignored'
      Set SHELLSPEC_SUBJECT="foo${SHELLSPEC_LF}"
      When invoke modifier line 2 _modifier_
      The status should be failure
    End

    Example 'only last LF should ignored'
      Set SHELLSPEC_SUBJECT="foo${SHELLSPEC_LF}${SHELLSPEC_LF}"
      When invoke modifier line 2 _modifier_
      The entire stdout should equal ""
    End

    Example 'empty subject should be undefined'
      Set SHELLSPEC_SUBJECT=""
      When invoke modifier line 1 _modifier_
      The status should be failure
    End

    Example 'LF only subject should equal ""'
      Set SHELLSPEC_SUBJECT="${SHELLSPEC_LF}"
      When invoke modifier line 1 _modifier_
      The entire stdout should equal ""
    End

    Example 'can not get number of line of undefined subject'
      Unset SHELLSPEC_SUBJECT
      When invoke modifier line 2 _modifier_
      The status should be failure
    End

    Example 'output error if value is not a number'
      Set SHELLSPEC_SUBJECT="foo${SHELLSPEC_LF}bar${SHELLSPEC_LF}baz"
      When invoke modifier line ni
      The stderr should equal SYNTAX_ERROR_PARAM_TYPE
    End

    Example 'output error if value is missing'
      Set SHELLSPEC_SUBJECT="foo${SHELLSPEC_LF}bar${SHELLSPEC_LF}baz"
      When invoke modifier line
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End

    Example 'output error if next word is missing'
      Set SHELLSPEC_SUBJECT="foo${SHELLSPEC_LF}bar${SHELLSPEC_LF}baz"
      When invoke modifier line 2
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
