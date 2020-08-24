#shellcheck shell=sh

Describe "core/modifiers/length.sh"
  BeforeRun set_subject modifier_mock

  Describe "length modifier"
    Example 'example'
      The length of value foobarbaz should equal 9
    End

    It 'counts length'
      subject() { %- "abcde"; }
      preserve() { %preserve SHELLSPEC_META:META; }
      AfterRun preserve

      When run shellspec_modifier_length _modifier_
      The stdout should equal 5
      The variable META should eq 'number'
    End

    It 'can not counts length undefined'
      subject() { false; }
      When run shellspec_modifier_length _modifier_
      The status should be failure
    End

    It 'outputs error if next modifier is missing'
      subject() { %- "abcde"; }
      When run shellspec_modifier length
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
