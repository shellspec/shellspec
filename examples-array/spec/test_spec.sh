#shellcheck shell=bash

Describe 'array module'
  Describe 'create_array()'
    create_array() {
      #shellcheck disable=SC2034
      TEST_ARRAY=("aa" "bb" "c c c")
    }

    It 'should create an array with 3 items'
      When call create_array
      The array 'TEST_ARRAY' should be size 3
    End
  End
End
