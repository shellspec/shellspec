#shellcheck shell=sh

Describe "core/subjects/variable.sh"
  Describe "variable subject"
    Example 'exampe'
      Set var=foo
      The variable var should equal foo
    End

    Example "retrive variable should equal test with newline"
      Set var="test${SHELLSPEC_LF}"
      When invoke subject variable var _modifier_
      The entire stdout should equal "test${SHELLSPEC_LF}"
    End

    Example "retrive variable should equal '' if empty string"
      Set var=
      When invoke subject variable var _modifier_
      The entire stdout should equal ''
    End

    Example "retrive variable should be undefined if unset variable"
      Unset var
      When invoke subject variable var _modifier_
      The status should be failure
    End

    Example 'output error if value is missing'
      When invoke subject variable
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End

    Example 'output error if next word is missing'
      When invoke subject variable var
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
