Describe 'sample' # Example group block
  Describe 'bc command'
    add() { echo "$1 + $2" | bc; }

    It 'performs addition' # Example block
      When call add 2 3 # Evaluation
      The output should eq 5  # Expectation
    End
  End

  Describe 'implemented by shell function'
    Include ./mylib.sh # add() function defined

    It 'performs addition'
      When call add 2 3
      The output should eq 5
    End
  End
End
