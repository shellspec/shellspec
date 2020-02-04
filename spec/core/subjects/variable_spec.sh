#shellcheck shell=sh disable=SC2016

Describe "core/subjects/variable.sh"
  BeforeRun subject_mock

  Describe "variable subject"
    Context 'when var is foo'
      Before 'var=foo'
      Example 'example'
        The variable var should equal foo
      End
    End

    Context 'when the variable exists'
      Before "var='test${IFS%?}'"
      It 'uses the value of variable as subject'
        When run shellspec_subject variable var _modifier_
        The entire stdout should equal "test${IFS%?}"
      End
    End

    Context 'when the variable not exists'
      Before 'unset var ||:'
      It 'uses undefined as subject'
        When run shellspec_subject variable var _modifier_
        The status should be failure
      End
    End

    It 'outputs error if value is missing'
      When run shellspec_subject variable
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End

    It 'outputs error if next word is missing'
      When run shellspec_subject variable var
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
