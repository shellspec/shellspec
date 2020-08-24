#shellcheck shell=sh

Describe "core/subjects/path.sh"
  BeforeRun subject_mock

  Describe "path subject"
    Example 'example'
      Path bar=/tmp/bar
      The path "/tmp/foo" should equal "/tmp/foo"
      The path "bar" should equal "/tmp/bar"
      The file "/tmp/foo" should equal "/tmp/foo" # alias for path
      The dir "/tmp/foo" should equal "/tmp/foo" # alias for path
      The directory "/tmp/foo" should equal "/tmp/foo" # alias for path
    End

    It "uses parameter as subject When run shellspec_subject_path"
      preserve() { %preserve SHELLSPEC_META:META; }
      AfterRun preserve

      When run shellspec_subject_path foo _modifier_
      The stdout should equal 'foo'
      The variable META should eq 'path'
    End

    It "converts alias to path and uses as subject when path alias is exists"
      Path bar=/tmp/bar
      When run shellspec_subject_path bar _modifier_
      The stdout should equal '/tmp/bar'
    End

    It 'outputs error if path is missing'
      When run shellspec_subject_path
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End

    It 'outputs error if next word is missing'
      When run shellspec_subject_path bar
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
