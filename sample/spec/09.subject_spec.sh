#shellcheck shell=sh

Describe 'subject sample'
  Describe 'stdout'
    func() { echo "ok"; }

    It 'uses the stdout as the subject'
      When call func
      The stdout should eq "ok"
    End

    It 'has an alias "output"'
      When call func
      The output should eq "ok"
    End

    Describe 'with entire'
      It 'does not remove last LF'
        When call func
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
    func() { echo "err" >&2; }

    It 'uses the stderr as the subject'
      When call func
      The stderr should eq "err"
    End

    It 'has an alias "error"'
      When call func
      The error should eq "err"
    End

    Describe 'with entire'
      It 'does not remove last LF'
        When call func
        The entire error should eq "err${SHELLSPEC_LF}"
      End
    End
  End

  Describe 'status'
    func() { return 123; }

    It 'uses the status as the subject'
      When call func
      The status should eq 123
    End
  End

  Describe 'variable'
    func() { var=456; }

    It 'uses the variable as the subject'
      When call func
      The variable var should eq 456
      The '$var' should eq 456 # shorthand for function
    End
  End

  Describe 'value'
    func() { var=789; }

    It 'uses the value as the subject'
      When call func
      The value "$var" should eq 789
    End
  End

  Describe 'function'
    func() { echo "ok"; }

    It 'is alias for value'
      The function "func" should eq "func"
      The "func()" should eq "func" # shorthand for function
    End

    It 'uses with result modifier'
      The result of "func()" should eq "ok"
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

    It 'has an alias "file"'
      Path target='/foo/bar/baz/target'
      The dir target should eq '/foo/bar/baz/target'
    End

    It 'is same as value if path alias not found. but improve readability'
      The path '/etc/hosts' should eq '/etc/hosts'
    End
  End
End
