#shellcheck shell=sh

Describe "core/subjects/path.sh"
  Before intercept_shellspec_subject

  Describe "path subject"
    Example 'example'
      Path bar=/tmp/bar
      The path "/tmp/foo" should equal "/tmp/foo"
      The path "bar" should equal "/tmp/bar"
      The file "/tmp/foo" should equal "/tmp/foo" # alias for path
      The dir "/tmp/foo" should equal "/tmp/foo" # alias for path
      The directory "/tmp/foo" should equal "/tmp/foo" # alias for path
    End

    Context 'when path alias is not exists'
      It "uses parameter as subject"
        When invoke shellspec_subject path foo _modifier_
        The stdout should equal 'foo'
      End
    End

    Context 'when path alias is exists'
      Before 'shellspec_path bar=/tmp/bar'
      It "converts alias to path and uses as subject"
        When invoke shellspec_subject path bar _modifier_
        The stdout should equal '/tmp/bar'
      End
    End

    It 'outputs error if path is missing'
      When invoke shellspec_subject path
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End

    It 'outputs error if next word is missing'
      When invoke shellspec_subject path bar
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
