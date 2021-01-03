Describe 'example'
  Describe 'bc command'
    It 'performs addition'
      Data '2 + 3'
      When call bc
      The output should eq 5
    End
  End

  Describe 'add() function'
    Include ./mylib.sh # add() function defined
    It 'performs addition'
      When call add 2 3
      The output should eq 5
    End
  End
End
