#shellcheck shell=sh

Describe 'this is "example group"'
  Context 'this is also "example group"'
    # You can write an "example" here
  End

  Describe '"example group" can be nestable'
    # You can write an "example" here
  End

  Context 'this is also "example group"'
    # You can write an "example" here

    Describe '"example group" can be nestable'
      # You can write an "example" here
    End

    # You can write an "example" here
  End
  # You can write an "example" here
End

# You can write an "example" here
