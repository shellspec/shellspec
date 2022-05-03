# shellcheck shell=sh disable=SC2016,SC2286,SC2287,SC2288

Describe "core/subjects/value.sh"
  BeforeRun subject_mock

  Describe "value subject"
    Example 'example'
      The value foo should equal foo
      The function foo should equal foo # alias for value
    End

    It "uses parameter as subject"
      preserve() { %preserve SHELLSPEC_META:META; }
      AfterRun preserve

      When run shellspec_subject value foo _modifier_
      The stdout should equal 'foo'
      The variable META should eq 'text'
    End

    It 'outputs error if value is missing'
      When run shellspec_subject value
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End

    It 'outputs error if next word is missing'
      When run shellspec_subject value foo
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
