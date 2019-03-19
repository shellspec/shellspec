#shellcheck shell=sh

Describe "core/subjects/path.sh"
  Before 'shellspec_path bar=/tmp/bar'

  Describe "path subject"
    Example 'example'
      The path "/tmp/foo" should equal "/tmp/foo"
      The path "bar" should equal "/tmp/bar"
      The file "/tmp/foo" should equal "/tmp/foo" # alias for path
      The dir "/tmp/foo" should equal "/tmp/foo" # alias for path
      The directory "/tmp/foo" should equal "/tmp/foo" # alias for path
    End

    Example "use parameter as subject"
      When invoke spy_shellspec_subject path foo _modifier_
      The stdout should equal 'foo'
    End

    Example "use alias as subject"
      When invoke spy_shellspec_subject path bar _modifier_
      The stdout should equal '/tmp/bar'
    End

    Example 'outputs error if path is missing'
      When invoke spy_shellspec_subject path
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End

    Example 'outputs error if next word is missing'
      When invoke spy_shellspec_subject path bar
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
