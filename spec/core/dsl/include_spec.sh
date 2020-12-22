#shellcheck shell=sh disable=SC2016

% FIXTURE: "$SHELLSPEC_HELPERDIR/fixture"

Describe 'Include'
  Context 'with no arguments'
    set -- 1 2 3
    Include "$FIXTURE/include.sh"
    #shellcheck disable=SC2034
    IFS=' ' && ARGS="$*"

    It 'includes a file'
      The variable INCLUDED should eq 1
      The variable ARG1 should be undefined
      The variable ARG2 should be undefined
      The variable ARG3 should be undefined
      The variable ARGS should eq "1 2 3"
    End
  End

  Context 'with arguments'
    set -- 1 2 3
    Include "$FIXTURE/include.sh" A B C
    #shellcheck disable=SC2034
    IFS=' ' && ARGS="$*"

    It 'includes a file'
      The variable INCLUDED should eq 1
      The variable ARG1 should eq "A"
      The variable ARG2 should eq "B"
      The variable ARG3 should eq "C"
      The variable ARGS should eq "1 2 3"
    End
  End
End
