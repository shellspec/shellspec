#shellcheck shell=sh disable=SC2016

Describe "core/subjects/variable.sh"
  Before intercept_shellspec_subject

  Describe "variable subject"
    Context 'when var is foo'
      Before 'shellspec_set var=foo'
      Example 'example'
        The variable var should equal foo
        The '$var' should equal foo # shorthand
      End
    End

    Context 'when the variable exists'
      Before 'shellspec_set var="test${LF}"'
      It 'uses the value of variable as subject'
        When invoke shellspec_subject variable var _modifier_
        The entire stdout should equal "test${LF}"
      End
    End

    Context 'when the variable not exists'
      Before 'shellspec_unset var'
      It 'uses undefined as subject'
        When invoke shellspec_subject variable var _modifier_
        The status should be failure
      End
    End

    It 'outputs error if value is missing'
      When invoke shellspec_subject variable
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End

    It 'outputs error if next word is missing'
      When invoke shellspec_subject variable var
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
