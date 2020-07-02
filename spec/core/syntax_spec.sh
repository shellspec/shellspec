#shellcheck shell=sh disable=SC2016

Describe "core/syntax.sh"
  Include "$SHELLSPEC_LIB/core/syntax.sh"

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
    The 4nd word of stdout should equal "BAR"
    The "func()" should equal "func"
  End

  Describe "shellspec_syntax()"
    It "adds new syntax"
      BeforeRun 'SHELLSPEC_SYNTAXES=":syntax:"'
      AfterRun 'echo $SHELLSPEC_SYNTAXES'
      When run shellspec_syntax new_syntax
      The stdout should eq ":syntax:new_syntax:"
    End
  End

  Describe "shellspec_syntax_chain()"
    BeforeRun 'SHELLSPEC_SYNTAXES=":syntax:"'

    check() {
      shellspec_syntax_dispatch() { echo "$@"; }
      shellspec_matcher_foo a b c
      %preserve SHELLSPEC_SYNTAXES:syntaxes
    }
    AfterRun check

    It "adds new chain"
      When run shellspec_syntax_chain shellspec_matcher_foo
      The stdout should eq "matcher_foo a b c"
      The variable syntaxes should eq ":syntax:shellspec_matcher_foo:"
    End
  End

  Describe "shellspec_syntax_compound()"
    BeforeRun 'SHELLSPEC_SYNTAXES=":syntax:"' 'SHELLSPEC_COMPOUNDS=":compund:"'

    check() {
      shellspec_syntax_dispatch() { echo "$@"; }
      shellspec_matcher_foo a b c
      %preserve SHELLSPEC_SYNTAXES:syntaxes SHELLSPEC_COMPOUNDS:compounds
    }
    AfterRun check

    It "adds new compound"
      When run shellspec_syntax_compound shellspec_matcher_foo
      The stdout should eq "matcher_foo a b c"
      The variable syntaxes should eq ":syntax:shellspec_matcher_foo:"
      The variable compounds should eq ":compund:shellspec_matcher_foo:"
    End
  End

  Describe "shellspec_syntax_alias()"
    BeforeRun 'SHELLSPEC_SYNTAXES=":syntax:"' 'shellspec_syntax syntax_foo'

    check() {
      syntax_foo() { echo "foo" "$@"; }
      syntax_bar a b c
      %preserve SHELLSPEC_SYNTAXES:syntaxes
    }
    AfterRun check

    It "adds new alias"
      When run shellspec_syntax_alias syntax_bar syntax_foo
      The variable syntaxes should eq ":syntax:syntax_foo:syntax_bar:"
      The stdout should eq "foo a b c"
    End
  End

  Describe "shellspec_syntax_dispatch()"
    mock() {
      shellspec_output() { echo "$@"; }
      shellspec_on() { echo "[$1]"; }
    }
    BeforeRun mock

    Context "general"
      setup() { shellspec_type_name() { eval echo type_name ${1+'"$@"'}; }; }
      BeforeRun 'SHELLSPEC_SYNTAXES=":shellspec_type_name:"' setup

      It "dispatches"
        When run shellspec_syntax_dispatch "type" "name"
        The stdout should eq "type_name"
      End

      It "dispatches with arguments"
        When run shellspec_syntax_dispatch "type" "name" arg
        The stdout should eq "type_name arg"
      End
    End

    Context "function subject shorthand"
      setup() { shellspec_subject_function() { echo "$@"; }; }
      BeforeRun 'SHELLSPEC_SYNTAXES=":shellspec_subject_function:"' setup

      It "dispatches"
        When run shellspec_syntax_dispatch "subject" "foo()"
        The stdout should eq "foo"
      End

      It "dispatches with arguments"
        When run shellspec_syntax_dispatch "subject" "foo()" arg
        The stdout should eq "foo arg"
      End
    End

    It "outputs error if unknown syntax type"
      BeforeRun 'SHELLSPEC_SYNTAXES=":shellspec_type_name:"'
      When run shellspec_syntax_dispatch "unknown" "name"
      The line 1 of stdout should eq "SYNTAX_ERROR_DISPATCH_FAILED unknown name"
      The line 2 of stdout should eq "[SYNTAX_ERROR]"
    End
  End

  Describe "shellspec_syntax_param()"
    mock() {
      shellspec_output() { echo "$@"; }
      shellspec_on() { echo "[$1]"; }
    }
    BeforeRun mock

    Describe 'number'
      It "succeeds if the parameters count satisfies the condition"
        When run shellspec_syntax_param count [ 1 -gt 0 ]
        The status should be success
      End

      It "fails if the parameters count not satisfies the condition"
        When run shellspec_syntax_param count [ 0 -gt 0 ]
        The status should be failure
        The stdout should include 'SYNTAX_ERROR_WRONG_PARAMETER_COUNT'
        The stdout should include '[SYNTAX_ERROR]'
      End
    End

    Describe 'N (parameter position)'
      It "succeeds if the parameter is number"
        When run shellspec_syntax_param 1 is number 123
        The status should be success
      End

      It "fails if the parameter is not number"
        When run shellspec_syntax_param 2 is number abc
        The status should be failure
        The stdout should include 'SYNTAX_ERROR_PARAM_TYPE 2'
        The stdout should include '[SYNTAX_ERROR]'
      End
    End

    It "raise errors with wrong parameter"
      When run shellspec_syntax_param wrong-parameter
      The error should be present
      The status should be failure
    End
  End
End
