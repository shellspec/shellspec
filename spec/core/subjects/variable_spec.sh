#shellcheck shell=sh disable=SC2016

Describe "core/subjects/variable.sh"
  Describe "variable subject"
    Context 'when var is foo'
      Before 'shellspec_set var=foo'
      Example 'exampe'
        The variable var should equal foo
        The '$var' should equal foo # shorthand
      End
    End

    Context 'when var is "test<LF>"'
      Before 'shellspec_set var="test${LF}"'
      Example 'it should equal "test<LF>"'
        When invoke spy_shellspec_subject variable var _modifier_
        The entire stdout should equal "test${LF}"
      End
    End

    Context 'when var is zero length string'
      Before 'shellspec_set var='
      Example 'it should equal ""'
        When invoke spy_shellspec_subject variable var _modifier_
        The entire stdout should equal ''
      End
    End

    Context 'when var is undefined'
      Before 'shellspec_unset var'
      Example 'it should be failure'
        When invoke spy_shellspec_subject variable var _modifier_
        The status should be failure
      End
    End

    Example 'output error if value is missing'
      When invoke spy_shellspec_subject variable
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End

    Example 'output error if next word is missing'
      When invoke spy_shellspec_subject variable var
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
