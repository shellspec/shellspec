#shellcheck shell=sh

Describe "core/syntax.sh"
  Example "example"
    example() {
      echo 1 FOO
      echo 2 BAR
      echo 3 BAZ
      echo 4 the
    }
    When call example

    The value "foo" should equal "foo"
    The length of value "foo" should equal 3
    The word 2 of value "foo bar baz" should equal "bar"
    The second word of value "foo bar baz" should equal "bar"
    The 2nd word of value "foo bar baz" should equal "bar"
    The 2nd word of value "foo bar baz" should equal "bar"
    The 2nd word of line 2 of stdout should equal "BAR"
    The 2nd word of the line 2 of the stdout should equal "BAR"
    The 2nd word of the line 4 of the stdout should equal "the"
  End

  Describe "shellspec_syntax_param()"
    shellspec_around_invoke() {
      shellspec_output() { echo "$*"; }
      shellspec_on() { echo "[$1]"; }
      "$@"
    }

    Describe 'number'
      Example "succeeds when the parameters count satisfies the condition"
        When invoke shellspec_syntax_param count [ 1 -gt 0 ]
        The status should be success
      End

      Example "fails when the parameters count not satisfies the condition"
        When invoke shellspec_syntax_param count [ 0 -gt 0 ]
        The status should be failure
        The stdout should include 'SYNTAX_ERROR_WRONG_PARAMETER_COUNT'
        The stdout should include '[SYNTAX_ERROR]'
      End
    End

    Describe 'N (parameter position)'
      Example "succeeds when the parameter is number"
        When invoke shellspec_syntax_param 1 is number 123
        The status should be success
      End

      Example "fails when the parameter is not number"
        When invoke shellspec_syntax_param 2 is number abc
        The status should be failure
        The stdout should include 'SYNTAX_ERROR_PARAM_TYPE 2'
        The stdout should include '[SYNTAX_ERROR]'
      End
    End
  End
End
