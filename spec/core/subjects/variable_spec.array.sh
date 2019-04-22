#shellcheck shell=sh disable=SC2016

# NOTE
#
# The index of array starts from 0 in the bash and ksh.
# The index of array starts from 1 in the zsh and yash.
# This test prove to variable subject accepts array with index, but does not
# prove that all shells start with the same index.

Describe "core/subjects/variable.array.sh"
  Before intercept_shellspec_subject

  Describe "variable subject"
    Context 'when var[2] is foo'
      Before 'var=(foo foo foo)'
      Example 'example'
        The variable "var[2]" should equal foo
      End
    End

    Context 'when the variable is array'
      Before 'var=(foo foo foo)'
      It 'accepts variable with index'
        When invoke shellspec_subject variable "var[2]" _modifier_
        The stdout should equal "foo"
      End
    End
  End
End
