#shellcheck shell=sh

Describe "core/subjects/line.sh"
  BeforeRun set_stdout subject_mock

  Describe "line subject"
    Example 'example'
      foobarbaz() { echo "foo"; echo "bar"; echo "baz"; }
      When call foobarbaz
      The line 2 should equal "bar"
    End

    It "gets specified line of stdout when stdout is defined"
      stdout() { echo "line1"; echo "line2"; echo "line3"; }
      When run shellspec_subject_line 2 _modifier_
      The stdout should equal 'line2'
    End

    It "gets undefined when stdout is undefined"
      stdout() { false; }
      When run shellspec_subject_line 1 _modifier_
      The status should be failure
    End
  End
End
