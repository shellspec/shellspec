#shellcheck shell=sh

Describe 'subject example'
  Describe 'stdout'
    foo() { echo "ok"; }

    It 'uses the stdout as the subject'
      When call foo
      The stdout should eq "ok"
    End

    It 'has an alias "output"'
      When call foo
      The output should eq "ok"
    End

    Describe 'with entire'
      It 'does not remove last LF'
        When call foo
        The entire output should eq "ok${SHELLSPEC_LF}"
      End

      # Without "entire", the "output" subject act as like
      # the command substitution.
      #
      # For example "echo" outputs a newline at the end.
      # In spite of that `[ "$(echo ok)" = "ok" ]` will success.
      # Because the command substitution removes trailing newlines.
      #
      # The "entire output" subject does not remove trailing newlines.
    End
  End

  Describe 'stderr'
    foo() { echo "err" >&2; }

    It 'uses the stderr as the subject'
      When call foo
      The stderr should eq "err"
    End

    It 'has an alias "error"'
      When call foo
      The error should eq "err"
    End

    Describe 'with entire'
      It 'does not remove last LF'
        When call foo
        The entire error should eq "err${SHELLSPEC_LF}"
      End
    End
  End

  Describe 'status'
    foo() { return 123; }

    It 'uses the status as the subject'
      When call foo
      The status should eq 123
    End
  End

  Describe 'variable'
    foo() { var=456; }

    It 'uses the variable as the subject'
      When call foo
      The variable var should eq 456
    End
  End

  Describe 'value'
    foo() { var=789; }

    It 'uses the value as the subject'
      When call foo
      The value "$var" should eq 789
    End
  End

  Describe 'function'
    foo() { echo "ok"; }

    It 'is alias for value'
      The function "foo" should eq "foo"
      The "foo()" should eq "foo" # shorthand for function
    End

    It 'uses with result modifier'
      The result of "foo()" should eq "ok"
    End
  End

  Describe 'path'
    # Path helper defines path alias.
    Path hosts-file='/etc/hosts'

    It 'uses the resolved path as the subject'
      The path hosts-file should eq '/etc/hosts'
    End

    It 'has an alias "file"'
      Path hosts='/etc/hosts'
      The file hosts should eq '/etc/hosts'
    End

    It 'has an alias "dir"'
      Path target='/foo/bar/baz/target'
      The dir target should eq '/foo/bar/baz/target'
    End

    It 'is same as value if path alias not found. but improve readability'
      The path '/etc/hosts' should eq '/etc/hosts'
    End
  End
End
