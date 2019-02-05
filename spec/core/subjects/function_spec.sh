#shellcheck shell=sh

Describe "core/subjects/function.sh"
  Describe "function subject"
    func() { echo foo; }

    Example 'example'
      The function func should equal foo
      The function func should not equal bar
    End

    Example "use parameter as subject"
      When invoke subject function func _modifier_
      The stdout should equal 'foo'
    End

    Example 'output error if value is missing'
      When invoke subject function
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End

    Example 'output error if next word is missing'
      When invoke subject function func
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
