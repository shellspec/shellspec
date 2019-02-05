#shellcheck shell=sh

Describe "core/modifiers/length.sh"
  Describe "length modifier"
    Example 'example'
      The length of value foobarbaz should equal 9
    End

    Example 'get length of subjet'
      Set SHELLSPEC_SUBJECT=abcde
      When invoke modifier length _modifier_
      The stdout should equal 5
    End

    Example 'cant get length of undefined subjet'
      Unset SHELLSPEC_SUBJECT
      When invoke modifier length _modifier_
      The status should be failure
    End

    Example 'output error if next modifier is missing'
      Set SHELLSPEC_SUBJECT=abcde
      When invoke modifier length
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
