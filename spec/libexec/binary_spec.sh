#shellcheck shell=sh

Describe "libexec/binary.sh"
  Describe 'octal_dump()'
    Include "$SHELLSPEC_LIB/libexec/binary.sh"

    It 'outputs as octal number'
      Data "abc"
      When call octal_dump
      The line 1 of stdout should eq '141'
      The line 2 of stdout should eq '142'
      The line 3 of stdout should eq '143'
      The line 4 of stdout should eq '012'
    End
  End
End
