#shellcheck shell=sh

Describe 'modifier sample'
  data() {
    echo '1 a A'
    echo '2 b B'
    echo '3 c C'
    echo '4 d D'
  }

  Describe 'line modifier'
    It 'gets specified line'
      When call data
      The line 2 of stdout should eq "2 b B"
      The stdout line 2 should eq "2 b B" # you can also write like this
    End
  End

  Describe 'lines modifier'
    It 'counts lines'
      When call data
      The lines of stdout should eq 4
    End
  End

  Describe 'word modifier'
    It 'gets specified word'
      When call data
      The word 5 of stdout should eq "b"
    End
  End

  Describe 'length modifier'
    It 'counts length'
      When call data
      The length of stdout should eq 23 # 6 * 4 - 1
      # Each lines length is 6 including newline,
      # but trailing newlines are removed.
    End
  End

  Describe 'contents modifier'
    It 'counts length'
      The contents of file "data.txt" should eq "data"
    End
  End

  Describe 'result modifier'
    echo_ok() { echo ok; }
    It 'calls function'
      The result of function echo_ok should eq "ok"
    End
  End

  Describe 'modifier'
    It 'can use ordinal number (0 - 20)'
      When call data
      The second line of stdout should eq "2 b B"
    End

    It 'can use abbreviation of ordinal number'
      When call data
      The 2nd line of stdout should eq "2 b B"
    End

    It 'is chainable'
      When call data
      The word 2 of line 2 of stdout should eq "b"
    End

    It 'can use language chain'
      When call data
      The word 2 of the line 2 of the stdout should eq "b"
    End
  End
End
