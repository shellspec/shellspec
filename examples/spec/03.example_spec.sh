#shellcheck shell=sh

Describe 'example example'
  It 'is "example"'
    When call echo 'foo'
    The output should eq 'foo'
  End

  Example 'is "example"'
    When call echo 'bar'
    The output should eq 'bar'
  End

  Specify 'is also "example"'
    When call echo 'baz'
    The output should eq 'baz'
  End

  Example 'this is "Not yot implemented" example block'
    :
  End

  Todo 'what to do' # same as "Not yot implemented" example but not block

  It 'not allows define "example group" in "example"'
    # Describe 'example group'
    #   this is syntax error
    # End
    The value 1 should eq 1
  End
End

# example group is not required
It 'is "example" without "example group"'
  When call echo 'foo'
  The output should eq 'foo'
End
