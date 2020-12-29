#shellcheck shell=sh

Describe "core/subjects/line.sh"
  BeforeRun set_stdout subject_mock

  Describe "line subject"
    Example 'example'
      foobarbaz() { echo "foo"; echo "bar"; echo "baz"; echo; }
      When call foobarbaz
      The line 2 should equal "bar"
      The line 3 should equal "baz"
      The line 4 should be undefined
      The line 4 of output should be undefined
    End

    It "gets specified line of stdout when stdout is defined"
      stdout() { echo "line1"; echo "line2"; echo "line3"; }
      preserve() { %preserve SHELLSPEC_META:META; }
      AfterRun preserve

      When run shellspec_subject_line 2 _modifier_
      The stdout should equal 'line2'
      The variable META should eq 'text'
    End

    It "gets undefined when stdout is undefined"
      stdout() { false; }
      When run shellspec_subject_line 1 _modifier_
      The status should be failure
    End
  End
End
